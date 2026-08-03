import CryptoKit
import EventKit
import Foundation
import GoogleSignIn
import LocalAuthentication
import Security
import SwiftUI
import UIKit
import WidgetKit

private enum NativeConfiguration {
    static let gmailReadonlyScope = "https://www.googleapis.com/auth/gmail.readonly"
    static let gmailComposeScope = "https://www.googleapis.com/auth/gmail.compose"
    static let appGroup = "group.com.velvetapplication.fait"
    static let keychainService = "com.velvetapplication.fait.google-session"
    static let keychainAccount = "primary"

    static var backendBaseURL: URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "FAITBackendBaseURL") as? String else { return nil }
        return URL(string: raw)
    }

    static var googleClientID: String? {
        Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String
    }

    static var googleServerClientID: String? {
        Bundle.main.object(forInfoDictionaryKey: "GIDServerClientID") as? String
    }

    static var googleIsConfigured: Bool {
        guard let client = googleClientID, let server = googleServerClientID else { return false }
        return client.contains(".apps.googleusercontent.com")
            && server.contains(".apps.googleusercontent.com")
            && !client.contains("REPLACE")
            && !server.contains("REPLACE")
    }
}

private enum KeychainSessionStore {
    static func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: NativeConfiguration.keychainService,
            kSecAttrAccount as String: NativeConfiguration.keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func save(_ value: String) throws {
        let data = Data(value.utf8)
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: NativeConfiguration.keychainService,
            kSecAttrAccount as String: NativeConfiguration.keychainAccount,
        ]
        SecItemDelete(base as CFDictionary)
        let attributes = base.merging([
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]) { _, new in new }
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else { throw NativeIntegrationError.keychain(status) }
    }

    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: NativeConfiguration.keychainService,
            kSecAttrAccount as String: NativeConfiguration.keychainAccount,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum NativeIntegrationError: LocalizedError {
    case configuration(String)
    case noPresenter
    case noAuthorizationCode
    case invalidResponse
    case backend(String)
    case permissionDenied(String)
    case keychain(OSStatus)

    var errorDescription: String? {
        switch self {
        case .configuration(let value): value
        case .noPresenter: "Impossible d’ouvrir la connexion Google."
        case .noAuthorizationCode: "Google n’a pas fourni le code sécurisé attendu."
        case .invalidResponse: "La réponse du service est illisible."
        case .backend(let value): value
        case .permissionDenied(let value): value
        case .keychain(let status): "Le Trousseau iPhone a refusé l’enregistrement (\(status))."
        }
    }
}

@MainActor
final class AppSecurityController: ObservableObject {
    @Published private(set) var isLocked = false
    @Published private(set) var lastError: String?
    @Published var faceIDEnabled: Bool {
        didSet { UserDefaults.standard.set(faceIDEnabled, forKey: "fait.faceIDEnabled") }
    }

    init() {
        faceIDEnabled = UserDefaults.standard.bool(forKey: "fait.faceIDEnabled")
    }

    var biometricLabel: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "Biométrie"
        }
    }

    func setEnabled(_ enabled: Bool) {
        faceIDEnabled = enabled
        if enabled {
            lock()
            Task { await unlock() }
        } else {
            isLocked = false
        }
    }

    func lock() {
        guard faceIDEnabled else { return }
        isLocked = true
    }

    func unlock() async {
        guard faceIDEnabled else {
            isLocked = false
            return
        }
        let context = LAContext()
        context.localizedCancelTitle = "Rester verrouillé"
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            lastError = error?.localizedDescription ?? "Face ID n’est pas disponible sur cet appareil."
            return
        }
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Déverrouiller vos dossiers, e-mails et rendez-vous."
            )
            if success {
                isLocked = false
                lastError = nil
            }
        } catch {
            lastError = error.localizedDescription
        }
    }
}

actor DeviceCalendarService {
    private let store = EKEventStore()

    func addEvent(
        title: String,
        notes: String,
        startDate: Date,
        reminderMinutes: Int?
    ) async throws -> String {
        let granted = try await store.requestWriteOnlyAccessToEvents()
        guard granted else {
            throw NativeIntegrationError.permissionDenied("L’accès en écriture au calendrier a été refusé.")
        }
        let event = EKEvent(eventStore: store)
        event.title = title
        event.notes = notes
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(60 * 60)
        event.calendar = store.defaultCalendarForNewEvents
        if let reminderMinutes {
            event.addAlarm(EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60)))
        }
        try store.save(event, span: .thisEvent, commit: true)
        return event.eventIdentifier
    }
}

private struct MobileExchangeResponse: Decodable {
    struct Account: Decodable {
        let email: String?
        let name: String?
        let picture: String?
    }
    let account: Account
    let scopes: [String]
    let sessionToken: String
}

private struct MobileSyncResponse: Decodable {
    let items: [GmailDetectedItemDTO]
    let lastSyncAt: String?
    let sessionToken: String
}

private struct MobileDraftResponse: Decodable {
    struct Draft: Decodable { let id: String }
    let draft: Draft
    let sessionToken: String
}

private struct GmailDetectedItemDTO: Decodable {
    let id: String
    let threadId: String
    let messageIdHeader: String?
    let from: String
    let fromEmail: String
    let subject: String
    let snippet: String
    let receivedAt: String
    let category: String
    let confidence: Double
    let amount: String?
    let dateText: String?
    let timeText: String?
    let suggestedAction: String
    let dossierTitle: String
    let suggestedReply: String
    let gmailUrl: String
}

@MainActor
final class NativeIntegrationController: ObservableObject {
    @Published private(set) var gmailConnected = false
    @Published private(set) var gmailComposeAuthorized = false
    @Published private(set) var gmailAccount = "Aucun compte"
    @Published private(set) var isWorking = false
    @Published private(set) var lastSyncAt: Date?
    @Published var statusMessage: String?

    private let calendarService = DeviceCalendarService()
    private var sessionToken: String? = KeychainSessionStore.load()

    init() {
        gmailConnected = sessionToken != nil
        configureGoogleSignIn()
    }

    func configureGoogleSignIn() {
        guard NativeConfiguration.googleIsConfigured,
              let clientID = NativeConfiguration.googleClientID,
              let serverClientID = NativeConfiguration.googleServerClientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: clientID,
            serverClientID: serverClientID
        )
    }

    func connectGmail(includeCompose: Bool, environment: AppEnvironment) async {
        guard NativeConfiguration.googleIsConfigured else {
            statusMessage = "Renseignez GIDClientID, GIDServerClientID et le schéma URL Google dans Info.plist."
            return
        }
        guard let presenter = UIApplication.shared.faitTopViewController else {
            statusMessage = NativeIntegrationError.noPresenter.localizedDescription
            return
        }
        isWorking = true
        defer { isWorking = false }
        do {
            let scopes = includeCompose
                ? [NativeConfiguration.gmailReadonlyScope, NativeConfiguration.gmailComposeScope]
                : [NativeConfiguration.gmailReadonlyScope]

            let result: GIDSignInResult
            if let current = GIDSignIn.sharedInstance.currentUser {
                let granted = Set(current.grantedScopes ?? [])
                let missing = scopes.filter { !granted.contains($0) }
                if missing.isEmpty {
                    GIDSignIn.sharedInstance.signOut()
                    result = try await GIDSignIn.sharedInstance.signIn(
                        withPresenting: presenter,
                        hint: current.profile?.email,
                        additionalScopes: scopes
                    )
                } else {
                    result = try await current.addScopes(missing, presenting: presenter)
                }
            } else {
                result = try await GIDSignIn.sharedInstance.signIn(
                    withPresenting: presenter,
                    hint: nil,
                    additionalScopes: scopes
                )
            }

            guard let code = result.serverAuthCode else {
                throw NativeIntegrationError.noAuthorizationCode
            }
            try await exchangeAuthorizationCode(code)
            gmailComposeAuthorized = Set(result.user.grantedScopes ?? []).contains(NativeConfiguration.gmailComposeScope)
            gmailAccount = result.user.profile?.email ?? gmailAccount
            gmailConnected = true
            await syncGmail(environment: environment)
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func syncGmail(environment: AppEnvironment) async {
        guard let sessionToken else {
            statusMessage = "Connectez Gmail avant de lancer la synchronisation."
            return
        }
        isWorking = true
        defer { isWorking = false }
        do {
            let response: MobileSyncResponse = try await request(
                path: "/api/mobile/gmail/sync",
                method: "POST",
                sessionToken: sessionToken,
                body: Optional<String>.none
            )
            try persistSession(response.sessionToken)
            lastSyncAt = response.lastSyncAt.flatMap(ISO8601DateFormatter().date(from:)) ?? .now
            merge(items: response.items, into: environment)
            publishWidgetSnapshot(from: environment)
            statusMessage = "Gmail synchronisé : \(response.items.count) élément(s) utile(s) détecté(s)."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func createGmailDraft(
        signal: ConnectedSignal,
        recipient: String,
        subject: String,
        body: String,
        environment: AppEnvironment
    ) async -> Bool {
        if !gmailComposeAuthorized {
            await connectGmail(includeCompose: true, environment: environment)
            guard gmailComposeAuthorized else { return false }
        }
        guard let sessionToken else { return false }
        isWorking = true
        defer { isWorking = false }
        do {
            struct Payload: Encodable {
                let to: String
                let subject: String
                let body: String
                let threadId: String?
                let inReplyTo: String?
            }
            let payload = Payload(
                to: recipient,
                subject: subject,
                body: body,
                threadId: signal.metadata["gmailThreadID"],
                inReplyTo: signal.metadata["gmailMessageHeader"]
            )
            let response: MobileDraftResponse = try await request(
                path: "/api/mobile/gmail/drafts",
                method: "POST",
                sessionToken: sessionToken,
                body: payload
            )
            try persistSession(response.sessionToken)
            _ = environment.createDraft(for: signal.id, recipient: recipient, subject: subject, body: body)
            statusMessage = "Brouillon Gmail créé. Aucun message n’a été envoyé."
            publishWidgetSnapshot(from: environment)
            return true
        } catch {
            statusMessage = error.localizedDescription
            return false
        }
    }

    func addToDeviceCalendar(signal: ConnectedSignal, environment: AppEnvironment) async -> Bool {
        guard let date = signal.dueDate else {
            statusMessage = "La date du rendez-vous doit être vérifiée."
            return false
        }
        isWorking = true
        defer { isWorking = false }
        do {
            _ = try await calendarService.addEvent(
                title: signal.title,
                notes: "Ajouté par FAIT. · Source : \(signal.source)",
                startDate: date,
                reminderMinutes: 24 * 60
            )
            _ = environment.addAgendaEvent(from: signal.id, syncToDevice: true)
            publishWidgetSnapshot(from: environment)
            statusMessage = "Rendez-vous ajouté au calendrier de l’iPhone."
            return true
        } catch {
            statusMessage = error.localizedDescription
            return false
        }
    }

    func disconnectGmail(environment: AppEnvironment) async {
        if let token = sessionToken {
            struct Empty: Encodable {}
            do {
                let _: EmptyResponse = try await request(
                    path: "/api/mobile/google/revoke",
                    method: "POST",
                    sessionToken: token,
                    body: Empty()
                )
            } catch {
                // La suppression locale reste prioritaire.
            }
        }
        GIDSignIn.sharedInstance.signOut()
        KeychainSessionStore.delete()
        sessionToken = nil
        gmailConnected = false
        gmailComposeAuthorized = false
        gmailAccount = "Aucun compte"
        if let index = environment.connections.firstIndex(where: { $0.service.localizedCaseInsensitiveContains("Gmail") }) {
            environment.connections[index].state = .disconnected
            environment.connections[index].account = "Aucun compte"
        }
        statusMessage = "Connexion Gmail révoquée sur cet iPhone."
    }

    func publishWidgetSnapshot(from environment: AppEnvironment) {
        SharedWidgetStore.save(
            pendingCount: environment.pendingConfirmationCount,
            activeCount: environment.activeCaseCount,
            nextTitle: environment.agendaEvents.sorted(by: { $0.startDate < $1.startDate }).first?.title,
            nextDate: environment.agendaEvents.sorted(by: { $0.startDate < $1.startDate }).first?.startDate,
            headline: environment.signals.first?.title
        )
    }

    private func exchangeAuthorizationCode(_ code: String) async throws {
        struct Payload: Encodable {
            let serverAuthCode: String
            let previousSessionToken: String?
        }
        let response: MobileExchangeResponse = try await request(
            path: "/api/mobile/google/exchange",
            method: "POST",
            sessionToken: nil,
            body: Payload(serverAuthCode: code, previousSessionToken: sessionToken)
        )
        try persistSession(response.sessionToken)
        gmailAccount = response.account.email ?? response.account.name ?? "Compte Google"
        gmailComposeAuthorized = response.scopes.contains(NativeConfiguration.gmailComposeScope)
        gmailConnected = true
    }

    private func persistSession(_ value: String) throws {
        sessionToken = value
        try KeychainSessionStore.save(value)
    }

    private func merge(items: [GmailDetectedItemDTO], into environment: AppEnvironment) {
        let existingIDs = Set(environment.signals.compactMap { $0.metadata["gmailMessageID"] })
        let incoming = items
            .filter { !existingIDs.contains($0.id) }
            .map(makeSignal)
        environment.signals.insert(contentsOf: incoming, at: 0)
        if let index = environment.connections.firstIndex(where: { $0.service.localizedCaseInsensitiveContains("Gmail") }) {
            environment.connections[index].state = .connected
            environment.connections[index].account = gmailAccount
            environment.connections[index].lastUsedAt = .now
            environment.connections[index].permissions = gmailComposeAuthorized
                ? ["Lire les messages utiles", "Créer des brouillons sans envoi"]
                : ["Lire les messages utiles"]
        }
    }

    private func makeSignal(_ item: GmailDetectedItemDTO) -> ConnectedSignal {
        let kind: SignalKind = switch item.category {
        case "invoice": .invoice
        case "appointment": .appointment
        case "contract": .contract
        default: .administrative
        }
        var metadata: [String: String] = [
            "gmailMessageID": item.id,
            "gmailThreadID": item.threadId,
            "replyTo": item.fromEmail,
            "gmailURL": item.gmailUrl,
            "suggestedReply": item.suggestedReply,
        ]
        if let messageID = item.messageIdHeader { metadata["gmailMessageHeader"] = messageID }
        if let value = item.dateText { metadata["dateText"] = value }
        if let value = item.timeText { metadata["timeText"] = value }
        return ConnectedSignal(
            id: deterministicUUID(item.id),
            kind: kind,
            source: "Gmail · \(item.from)",
            sender: item.from,
            receivedAt: ISO8601DateFormatter().date(from: item.receivedAt) ?? .now,
            title: item.subject,
            summary: item.snippet,
            state: kind == .appointment ? .needsConfirmation : .detected,
            suggestedAction: item.suggestedAction,
            confidence: item.confidence > 1 ? item.confidence / 100 : item.confidence,
            dueDate: nil,
            amount: parseAmount(item.amount),
            metadata: metadata
        )
    }

    private func deterministicUUID(_ value: String) -> UUID {
        let digest = SHA256.hash(data: Data(value.utf8))
        let bytes = Array(digest.prefix(16))
        let tuple: uuid_t = (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        )
        return UUID(uuid: tuple)
    }

    private func parseAmount(_ raw: String?) -> Decimal? {
        guard let raw else { return nil }
        let normalized = raw
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    private func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        sessionToken: String?,
        body: Body?
    ) async throws -> Response {
        guard let baseURL = NativeConfiguration.backendBaseURL,
              let url = URL(string: path, relativeTo: baseURL) else {
            throw NativeIntegrationError.configuration("L’adresse du backend FAIT. est absente de Info.plist.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let sessionToken { request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization") }
        if let body { request.httpBody = try JSONEncoder().encode(body) }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NativeIntegrationError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let detail = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["detail"] as? String
            throw NativeIntegrationError.backend(detail ?? "Le service FAIT. a répondu avec l’erreur \(http.statusCode).")
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

private struct EmptyResponse: Decodable { let ok: Bool }

private extension UIApplication {
    var faitTopViewController: UIViewController? {
        let window = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        var controller = window?.rootViewController
        while let presented = controller?.presentedViewController { controller = presented }
        if let navigation = controller as? UINavigationController { return navigation.visibleViewController }
        if let tab = controller as? UITabBarController { return tab.selectedViewController }
        return controller
    }
}

struct SharedWidgetSnapshot: Codable {
    let updatedAt: Date
    let pendingCount: Int
    let activeCount: Int
    let nextTitle: String?
    let nextDate: Date?
    let headline: String?
}

enum SharedWidgetStore {
    private static let key = "fait.widget.snapshot"

    static func save(
        pendingCount: Int,
        activeCount: Int,
        nextTitle: String?,
        nextDate: Date?,
        headline: String?
    ) {
        let snapshot = SharedWidgetSnapshot(
            updatedAt: .now,
            pendingCount: pendingCount,
            activeCount: activeCount,
            nextTitle: nextTitle,
            nextDate: nextDate,
            headline: headline
        )
        guard let defaults = UserDefaults(suiteName: NativeConfiguration.appGroup),
              let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func load() -> SharedWidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: NativeConfiguration.appGroup),
              let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SharedWidgetSnapshot.self, from: data)
    }
}

struct NativeConnectionCard: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var integrations: NativeIntegrationController

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "envelope.badge.shield.half.filled")
                    .font(.title3)
                    .foregroundStyle(FAITColor.trustGreen)
                    .frame(width: 48, height: 48)
                    .background(FAITColor.softSage.opacity(0.24), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text("Gmail réel").font(.headline)
                    Text(integrations.gmailConnected ? integrations.gmailAccount : "Connexion OAuth sécurisée")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                ConnectionStateBadge(state: integrations.gmailConnected ? .connected : .disconnected)
            }

            Text("FAIT. analyse les messages utiles. La permission de créer des brouillons est demandée séparément et aucune route d’envoi n’existe.")
                .font(.subheadline).foregroundStyle(FAITColor.mutedText)

            if let lastSync = integrations.lastSyncAt {
                Label("Dernière synchronisation \(lastSync.formatted(date: .abbreviated, time: .shortened))", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption).foregroundStyle(FAITColor.trustGreen)
            }
            if let message = integrations.statusMessage {
                Text(message).font(.caption).foregroundStyle(.secondary)
            }

            if integrations.gmailConnected {
                HStack {
                    Button {
                        Task { await integrations.syncGmail(environment: environment) }
                    } label: {
                        Label("Synchroniser", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent).tint(FAITColor.trustGreen)
                    .disabled(integrations.isWorking)

                    if !integrations.gmailComposeAuthorized {
                        Button("Autoriser les brouillons") {
                            Task { await integrations.connectGmail(includeCompose: true, environment: environment) }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                Button("Révoquer Gmail", role: .destructive) {
                    Task { await integrations.disconnectGmail(environment: environment) }
                }
                .font(.subheadline.weight(.semibold))
            } else {
                Button {
                    Task { await integrations.connectGmail(includeCompose: false, environment: environment) }
                } label: {
                    Label("Connecter Gmail", systemImage: "person.crop.circle.badge.plus")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .disabled(integrations.isWorking)
            }
        }
        .padding(17)
        .glassCard(cornerRadius: 23)
    }
}

struct FaceIDSettingsCard: View {
    @EnvironmentObject private var security: AppSecurityController

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 12) {
                Image(systemName: "faceid")
                    .font(.title2)
                    .foregroundStyle(FAITColor.trustGreen)
                    .frame(width: 48, height: 48)
                    .background(FAITColor.softSage.opacity(0.24), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text("Verrouillage \(security.biometricLabel)").font(.headline)
                    Text("Protège les dossiers, e-mails et rendez-vous au retour dans l’app.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { security.faceIDEnabled },
                    set: { security.setEnabled($0) }
                ))
                .labelsHidden().tint(FAITColor.trustGreen)
            }
            if let error = security.lastError {
                Text(error).font(.caption).foregroundStyle(Color.orange)
            }
        }
        .padding(17)
        .glassCard(cornerRadius: 22)
    }
}

struct WidgetInformationCard: View {
    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: "widget.small")
                .font(.title2).foregroundStyle(FAITColor.trustGreen)
                .frame(width: 48, height: 48)
                .background(FAITColor.softSage.opacity(0.24), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("Widget FAIT. quotidien").font(.headline)
                Text("Affiche les décisions en attente et le prochain rendez-vous, sans révéler le contenu des e-mails.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(17)
        .glassCard(cornerRadius: 22)
    }
}
