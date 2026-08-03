import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var cases: [FAITCase]
    @Published var signals: [ConnectedSignal]
    @Published var agendaEvents: [AgendaEvent]
    @Published var connections: [ExternalConnection]
    @Published var autonomyRules: [AutonomyRule]
    @Published var drafts: [DraftPreview] = []
    @Published var toastMessage: String?

    init() {
        cases = DemoFixtures.cases
        signals = DemoFixtures.signals
        agendaEvents = DemoFixtures.agendaEvents
        connections = DemoFixtures.connections
        autonomyRules = DemoFixtures.autonomyRules
    }

    var pendingConfirmationCount: Int {
        signals.filter { $0.state == .needsConfirmation }.count
    }

    var activeCaseCount: Int {
        cases.filter { $0.status != .done }.count
    }

    func signal(id: UUID) -> ConnectedSignal? {
        signals.first(where: { $0.id == id })
    }

    func caseItem(id: UUID) -> FAITCase? {
        cases.first(where: { $0.id == id })
    }

    @discardableResult
    func createCase(from signalID: UUID) -> UUID? {
        if let existing = cases.first(where: { $0.sourceSignalID == signalID }) {
            showToast("Ce dossier existe déjà.")
            return existing.id
        }
        guard let signal = signal(id: signalID) else { return nil }

        let person = signal.metadata["person"] ?? "Foyer"
        let organization = signal.metadata["organization"] ?? signal.sender
        let nextAction: String
        let status: CaseStatus

        switch signal.kind {
        case .invoice:
            nextAction = "Vérifier le prélèvement"
            status = .inProgress
        case .appointment:
            nextAction = "Préparer le rendez-vous"
            status = .inProgress
        case .contract:
            nextAction = "Examiner le brouillon préparé"
            status = .needsUser
        case .administrative:
            nextAction = "Vérifier les pièces demandées"
            status = .toDo
        case .vacation:
            nextAction = "Confirmer l’inscription"
            status = .needsUser
        }

        let item = FAITCase(
            title: signal.title,
            organization: organization,
            person: person,
            summary: signal.summary,
            status: status,
            nextAction: nextAction,
            dueDate: signal.dueDate,
            amount: signal.amount,
            steps: steps(for: signal),
            events: [
                CaseEvent(
                    title: "Détecté par FAIT.",
                    detail: "Source : \(signal.source)",
                    date: signal.receivedAt
                ),
                CaseEvent(
                    title: "Dossier créé",
                    detail: "Les informations restent liées à leur source.",
                    date: .now
                )
            ],
            sourceSignalID: signal.id
        )
        cases.insert(item, at: 0)
        updateSignal(signalID, state: .prepared)
        showToast("Dossier ajouté à FAIT.")
        return item.id
    }

    @discardableResult
    func addAgendaEvent(from signalID: UUID, syncToDevice: Bool) -> UUID? {
        guard let signal = signal(id: signalID), let date = signal.dueDate else { return nil }

        if let existingIndex = agendaEvents.firstIndex(where: { $0.source == signal.source && $0.title == signal.title }) {
            agendaEvents[existingIndex].syncedToDevice = syncToDevice || agendaEvents[existingIndex].syncedToDevice
            updateSignal(signalID, state: .synchronized)
            showToast(syncToDevice ? "Événement synchronisé avec l’iPhone." : "Événement ajouté à l’agenda FAIT.")
            return agendaEvents[existingIndex].id
        }

        let event = AgendaEvent(
            title: signal.title,
            detail: signal.metadata["location"] ?? signal.summary,
            startDate: date,
            source: signal.source,
            linkedCaseID: cases.first(where: { $0.sourceSignalID == signalID })?.id,
            syncedToDevice: syncToDevice,
            reminderMinutes: 24 * 60
        )
        agendaEvents.append(event)
        agendaEvents.sort { $0.startDate < $1.startDate }
        updateSignal(signalID, state: .synchronized)
        showToast(syncToDevice ? "Événement synchronisé avec l’iPhone." : "Événement ajouté à l’agenda FAIT.")
        return event.id
    }

    @discardableResult
    func createDraft(for signalID: UUID, recipient: String, subject: String, body: String) -> DraftPreview? {
        guard signal(id: signalID) != nil else { return nil }
        let draft = DraftPreview(
            sourceSignalID: signalID,
            recipient: recipient,
            subject: subject,
            body: body,
            createdAt: .now
        )
        drafts.insert(draft, at: 0)
        updateSignal(signalID, state: .prepared)
        showToast("Brouillon Gmail simulé créé. Aucun e-mail n’a été envoyé.")
        return draft
    }

    func confirmVacation(signalID: UUID) {
        guard let signal = signal(id: signalID) else { return }
        _ = createCase(from: signalID)
        if let index = cases.firstIndex(where: { $0.sourceSignalID == signalID }) {
            cases[index].status = .inProgress
            cases[index].nextAction = "Attendre l’ouverture du kiosque"
            cases[index].events.append(
                CaseEvent(
                    title: "Préparation confirmée",
                    detail: "La réservation reste simulée dans cette version.",
                    date: .now
                )
            )
        }
        updateSignal(signal.id, state: .prepared)
        showToast("Inscription préparée. La validation finale restera obligatoire.")
    }

    func toggleConnection(id: UUID) {
        guard let index = connections.firstIndex(where: { $0.id == id }) else { return }
        switch connections[index].state {
        case .connected, .simulated:
            connections[index].state = .suspended
            showToast("Connexion suspendue.")
        case .suspended, .disconnected:
            connections[index].state = .simulated
            connections[index].lastUsedAt = .now
            showToast("Connexion réactivée en mode test.")
        }
    }

    func revokeConnection(id: UUID) {
        guard let index = connections.firstIndex(where: { $0.id == id }) else { return }
        connections[index].state = .disconnected
        connections[index].account = "Aucun compte"
        connections[index].lastUsedAt = nil
        showToast("Connexion révoquée.")
    }

    func toggleAutonomy(id: UUID) {
        guard let index = autonomyRules.firstIndex(where: { $0.id == id }) else { return }
        autonomyRules[index].enabled.toggle()
    }

    private func updateSignal(_ id: UUID, state: SignalState) {
        guard let index = signals.firstIndex(where: { $0.id == id }) else { return }
        signals[index].state = state
    }

    private func steps(for signal: ConnectedSignal) -> [CaseStep] {
        switch signal.kind {
        case .invoice:
            return [
                CaseStep(title: "Classer la facture", detail: "Rattacher la facture au logement.", state: .completed, owner: "FAIT."),
                CaseStep(title: "Vérifier le prélèvement", detail: "Contrôler le montant et la date.", state: .current, owner: "Vous"),
                CaseStep(title: "Archiver la preuve", detail: "Conserver la facture et le paiement.", state: .upcoming, owner: "FAIT.")
            ]
        case .appointment:
            return [
                CaseStep(title: "Ajouter à l’agenda", detail: "Créer l’événement et le rappel.", state: .current, owner: "Vous"),
                CaseStep(title: "Préparer le rendez-vous", detail: "Rassembler les informations utiles.", state: .upcoming, owner: "FAIT."),
                CaseStep(title: "Confirmer la présence", detail: "Vérifier l’horaire la veille.", state: .upcoming, owner: "Vous")
            ]
        case .contract:
            return [
                CaseStep(title: "Comprendre la modification", detail: "Comparer l’ancien et le nouveau tarif.", state: .completed, owner: "FAIT."),
                CaseStep(title: "Préparer une réponse", detail: "Un brouillon est proposé sans être envoyé.", state: .current, owner: "FAIT."),
                CaseStep(title: "Valider le contenu", detail: "Vous gardez la décision finale.", state: .upcoming, owner: "Vous")
            ]
        case .administrative:
            return [
                CaseStep(title: "Vérifier la demande", detail: "Contrôler la source et l’échéance.", state: .current, owner: "Vous"),
                CaseStep(title: "Réunir les documents", detail: "Préparer les pièces attendues.", state: .upcoming, owner: "FAIT.")
            ]
        case .vacation:
            return [
                CaseStep(title: "Vérifier les dates", detail: "Contrôler la période et l’enfant concerné.", state: .current, owner: "Vous"),
                CaseStep(title: "Préparer l’inscription", detail: "Préremplir les choix et pièces.", state: .upcoming, owner: "FAIT."),
                CaseStep(title: "Confirmer la réservation", detail: "La dernière étape exige votre accord.", state: .upcoming, owner: "Vous")
            ]
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(3))
            if toastMessage == message { toastMessage = nil }
        }
    }
}

enum DemoFixtures {
    private static let calendar = Calendar.current

    static let signals: [ConnectedSignal] = {
        let now = Date.now
        return [
            ConnectedSignal(
                kind: .appointment,
                source: "Gmail · Cabinet dentaire",
                sender: "Cabinet dentaire des Flandres",
                receivedAt: calendar.date(byAdding: .minute, value: -18, to: now) ?? now,
                title: "Rendez-vous dentaire confirmé",
                summary: "Un rendez-vous a été détecté le 18 août à 16 h 30. FAIT. propose un rappel 24 heures avant.",
                state: .needsConfirmation,
                suggestedAction: "Ajouter à l’agenda",
                confidence: 0.98,
                dueDate: calendar.date(bySettingHour: 16, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 15, to: now) ?? now),
                metadata: [
                    "location": "Cabinet dentaire · Lille",
                    "organization": "Cabinet dentaire des Flandres",
                    "person": "Cyril"
                ]
            ),
            ConnectedSignal(
                kind: .invoice,
                source: "Gmail · Énergie Démo",
                sender: "Énergie Démo",
                receivedAt: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                title: "Facture d’électricité disponible",
                summary: "Montant détecté : 86,40 €. Le prélèvement est prévu le 14 août. La facture peut être classée dans le dossier Logement.",
                state: .prepared,
                suggestedAction: "Vérifier le classement",
                confidence: 0.97,
                dueDate: calendar.date(byAdding: .day, value: 11, to: now),
                amount: Decimal(string: "86.40"),
                metadata: [
                    "organization": "Énergie Démo",
                    "person": "Foyer",
                    "reference": "FAC-2026-0814"
                ]
            ),
            ConnectedSignal(
                kind: .contract,
                source: "Gmail · Opérateur Démo",
                sender: "service-clients@operateur-demo.fr",
                receivedAt: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                title: "Hausse tarifaire de l’abonnement Internet",
                summary: "Le tarif augmente de 4 € par mois à partir de septembre. Une demande commerciale peut être préparée.",
                state: .prepared,
                suggestedAction: "Examiner le brouillon",
                confidence: 0.94,
                dueDate: calendar.date(byAdding: .day, value: 29, to: now),
                amount: Decimal(string: "4.00"),
                metadata: [
                    "organization": "Opérateur Démo",
                    "person": "Foyer",
                    "replyTo": "service-clients@operateur-demo.fr"
                ]
            ),
            ConnectedSignal(
                kind: .vacation,
                source: "Kiosque Famille · Ville Démo",
                sender: "Ville Démo",
                receivedAt: now,
                title: "Inscriptions au centre aéré bientôt ouvertes",
                summary: "FAIT. a préparé une simulation d’inscription pour Inès pendant la première semaine des vacances.",
                state: .needsConfirmation,
                suggestedAction: "Vérifier l’inscription",
                confidence: 0.91,
                dueDate: calendar.date(byAdding: .day, value: 21, to: now),
                amount: Decimal(string: "42.00"),
                metadata: [
                    "organization": "Kiosque Famille",
                    "person": "Inès",
                    "period": "24 au 28 août",
                    "formula": "Journée complète avec repas"
                ]
            ),
            ConnectedSignal(
                kind: .administrative,
                source: "Gmail · CAF du Nord",
                sender: "CAF du Nord",
                receivedAt: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                title: "Justificatif de domicile demandé",
                summary: "Un document récent est demandé pour poursuivre le traitement du dossier.",
                state: .detected,
                suggestedAction: "Créer un dossier",
                confidence: 0.89,
                dueDate: calendar.date(byAdding: .day, value: 12, to: now),
                metadata: [
                    "organization": "CAF du Nord",
                    "person": "Cyril"
                ]
            )
        ]
    }()

    static let agendaEvents: [AgendaEvent] = {
        let now = Date.now
        return [
            AgendaEvent(
                title: "Échéance CAF",
                detail: "Dernier contrôle avant transmission",
                startDate: calendar.date(byAdding: .day, value: 9, to: now) ?? now,
                source: "Dossier CAF",
                syncedToDevice: true,
                reminderMinutes: 24 * 60
            ),
            AgendaEvent(
                title: "Contrôle technique",
                detail: "Centre automobile · Lens",
                startDate: calendar.date(byAdding: .day, value: 28, to: now) ?? now,
                source: "Dossier Véhicule",
                syncedToDevice: true,
                reminderMinutes: 2 * 24 * 60
            )
        ]
    }()

    static let cases: [FAITCase] = {
        let now = Date.now
        return [
            FAITCase(
                title: "Justificatif CAF",
                organization: "CAF du Nord",
                person: "Cyril",
                summary: "Un justificatif de domicile doit être transmis.",
                status: .toDo,
                nextAction: "Vérifier la date limite",
                dueDate: calendar.date(byAdding: .day, value: 12, to: now),
                updatedAt: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                steps: [
                    CaseStep(title: "Vérifier la demande", detail: "Contrôler les informations détectées.", state: .current, owner: "Vous"),
                    CaseStep(title: "Ajouter le justificatif", detail: "Joindre une facture récente.", state: .upcoming, owner: "Vous")
                ]
            ),
            FAITCase(
                title: "Résiliation Internet",
                organization: "Opérateur Démo",
                person: "Foyer",
                summary: "Une demande de résiliation est prête à être validée.",
                status: .needsUser,
                nextAction: "Valider le courrier",
                dueDate: calendar.date(byAdding: .day, value: 5, to: now),
                updatedAt: calendar.date(byAdding: .day, value: -1, to: now) ?? now
            ),
            FAITCase(
                title: "Contrôle technique",
                organization: "Véhicule familial",
                person: "Cyril",
                summary: "Le prochain contrôle a été programmé.",
                status: .inProgress,
                nextAction: "Attendre le rendez-vous",
                dueDate: calendar.date(byAdding: .day, value: 28, to: now),
                updatedAt: calendar.date(byAdding: .day, value: -2, to: now) ?? now
            ),
            FAITCase(
                title: "Carte d’identité",
                organization: "Mairie",
                person: "Inès",
                summary: "Le renouvellement est terminé.",
                status: .done,
                nextAction: "Aucune action requise",
                dueDate: nil,
                updatedAt: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                proofTitle: "Confirmation de retrait"
            )
        ]
    }()

    static let connections: [ExternalConnection] = [
        ExternalConnection(
            service: "Gmail",
            account: "cyril.demo@gmail.com",
            systemImage: "envelope.fill",
            state: .simulated,
            permissions: ["Lire les messages autorisés", "Préparer des brouillons", "Aucun envoi automatique"],
            lastUsedAt: .now,
            automationSummary: "Détecter factures, contrats, rendez-vous et démarches"
        ),
        ExternalConnection(
            service: "Calendrier iPhone",
            account: "Calendrier personnel",
            systemImage: "calendar",
            state: .connected,
            permissions: ["Ajouter un événement après accord", "Créer un rappel", "Éviter les doublons"],
            lastUsedAt: .now,
            automationSummary: "Synchroniser uniquement les événements confirmés"
        ),
        ExternalConnection(
            service: "Outlook",
            account: "Aucun compte",
            systemImage: "tray.fill",
            state: .disconnected,
            permissions: [],
            automationSummary: "Disponible dans une phase ultérieure"
        )
    ]

    static let autonomyRules: [AutonomyRule] = [
        AutonomyRule(
            title: "Détecter les messages utiles",
            detail: "Classer et expliquer les nouveaux messages autorisés.",
            level: .observe,
            enabled: true,
            alwaysRequiresConfirmation: false
        ),
        AutonomyRule(
            title: "Créer des rappels internes",
            detail: "Ajouter une échéance réversible dans l’agenda FAIT.",
            level: .organize,
            enabled: true,
            alwaysRequiresConfirmation: false
        ),
        AutonomyRule(
            title: "Préparer les brouillons",
            detail: "Rédiger une réponse sans l’envoyer.",
            level: .prepare,
            enabled: true,
            alwaysRequiresConfirmation: false
        ),
        AutonomyRule(
            title: "Synchroniser avec l’iPhone",
            detail: "Créer un événement dans le calendrier choisi.",
            level: .confirm,
            enabled: true,
            alwaysRequiresConfirmation: true
        ),
        AutonomyRule(
            title: "Réservations et inscriptions",
            detail: "Préparer le parcours, puis demander l’accord final.",
            level: .confirm,
            enabled: true,
            alwaysRequiresConfirmation: true
        )
    ]
}
