import Foundation

enum AppTab: Hashable, CaseIterable {
    case home
    case cases
    case intake
    case detected
    case profile

    var title: String {
        switch self {
        case .home: "Accueil"
        case .cases: "Dossiers"
        case .intake: "Confier"
        case .detected: "Détecté"
        case .profile: "Profil"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .cases: "folder"
        case .intake: "plus"
        case .detected: "sparkles"
        case .profile: "person"
        }
    }
}

enum CaseStatus: String, CaseIterable, Codable, Hashable {
    case toDo = "À traiter"
    case inProgress = "En cours"
    case needsUser = "Besoin de vous"
    case done = "Fait"

    var systemImage: String {
        switch self {
        case .toDo: "clock"
        case .inProgress: "arrow.triangle.2.circlepath"
        case .needsUser: "person.crop.circle.badge.exclamationmark"
        case .done: "checkmark.circle.fill"
        }
    }
}

enum CaseStepState: String, Codable, Hashable {
    case completed = "Terminé"
    case current = "En cours"
    case upcoming = "À venir"
    case blocked = "Bloqué"
}

struct CaseStep: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var detail: String
    var state: CaseStepState
    var owner: String

    init(id: UUID = UUID(), title: String, detail: String, state: CaseStepState, owner: String) {
        self.id = id
        self.title = title
        self.detail = detail
        self.state = state
        self.owner = owner
    }
}

struct CaseEvent: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var detail: String
    var date: Date

    init(id: UUID = UUID(), title: String, detail: String, date: Date) {
        self.id = id
        self.title = title
        self.detail = detail
        self.date = date
    }
}

struct FAITCase: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var organization: String
    var person: String
    var summary: String
    var status: CaseStatus
    var nextAction: String
    var dueDate: Date?
    var updatedAt: Date
    var amount: Decimal?
    var steps: [CaseStep]
    var events: [CaseEvent]
    var proofTitle: String?
    var sourceSignalID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        organization: String,
        person: String,
        summary: String,
        status: CaseStatus,
        nextAction: String,
        dueDate: Date?,
        updatedAt: Date = .now,
        amount: Decimal? = nil,
        steps: [CaseStep] = [],
        events: [CaseEvent] = [],
        proofTitle: String? = nil,
        sourceSignalID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.organization = organization
        self.person = person
        self.summary = summary
        self.status = status
        self.nextAction = nextAction
        self.dueDate = dueDate
        self.updatedAt = updatedAt
        self.amount = amount
        self.steps = steps
        self.events = events
        self.proofTitle = proofTitle
        self.sourceSignalID = sourceSignalID
    }
}

enum SignalKind: String, Codable, Hashable, CaseIterable {
    case invoice = "Facture"
    case appointment = "Rendez-vous"
    case contract = "Contrat"
    case administrative = "Démarche"
    case vacation = "Famille"

    var systemImage: String {
        switch self {
        case .invoice: "doc.text"
        case .appointment: "calendar"
        case .contract: "doc.badge.gearshape"
        case .administrative: "building.columns"
        case .vacation: "figure.2.and.child.holdinghands"
        }
    }
}

enum SignalState: String, Codable, Hashable {
    case detected = "Détecté"
    case prepared = "Préparé"
    case needsConfirmation = "À confirmer"
    case synchronized = "Synchronisé"
    case done = "Fait"
}

struct ConnectedSignal: Identifiable, Codable, Hashable {
    let id: UUID
    var kind: SignalKind
    var source: String
    var sender: String
    var receivedAt: Date
    var title: String
    var summary: String
    var state: SignalState
    var suggestedAction: String
    var confidence: Double
    var dueDate: Date?
    var amount: Decimal?
    var metadata: [String: String]

    init(
        id: UUID = UUID(),
        kind: SignalKind,
        source: String,
        sender: String,
        receivedAt: Date = .now,
        title: String,
        summary: String,
        state: SignalState,
        suggestedAction: String,
        confidence: Double,
        dueDate: Date? = nil,
        amount: Decimal? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.source = source
        self.sender = sender
        self.receivedAt = receivedAt
        self.title = title
        self.summary = summary
        self.state = state
        self.suggestedAction = suggestedAction
        self.confidence = confidence
        self.dueDate = dueDate
        self.amount = amount
        self.metadata = metadata
    }
}

struct AgendaEvent: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var detail: String
    var startDate: Date
    var source: String
    var linkedCaseID: UUID?
    var syncedToDevice: Bool
    var reminderMinutes: Int?

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        startDate: Date,
        source: String,
        linkedCaseID: UUID? = nil,
        syncedToDevice: Bool = false,
        reminderMinutes: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.startDate = startDate
        self.source = source
        self.linkedCaseID = linkedCaseID
        self.syncedToDevice = syncedToDevice
        self.reminderMinutes = reminderMinutes
    }
}

enum ConnectionState: String, Codable, Hashable {
    case connected = "Connecté"
    case simulated = "Simulation"
    case suspended = "Suspendu"
    case disconnected = "Non connecté"
}

struct ExternalConnection: Identifiable, Codable, Hashable {
    let id: UUID
    var service: String
    var account: String
    var systemImage: String
    var state: ConnectionState
    var permissions: [String]
    var lastUsedAt: Date?
    var automationSummary: String

    init(
        id: UUID = UUID(),
        service: String,
        account: String,
        systemImage: String,
        state: ConnectionState,
        permissions: [String],
        lastUsedAt: Date? = nil,
        automationSummary: String
    ) {
        self.id = id
        self.service = service
        self.account = account
        self.systemImage = systemImage
        self.state = state
        self.permissions = permissions
        self.lastUsedAt = lastUsedAt
        self.automationSummary = automationSummary
    }
}

enum AutonomyLevel: Int, Codable, Hashable, CaseIterable {
    case observe = 0
    case organize = 1
    case prepare = 2
    case confirm = 3
    case limitedAutomatic = 4

    var title: String {
        switch self {
        case .observe: "Observer"
        case .organize: "Organiser"
        case .prepare: "Préparer"
        case .confirm: "Exécuter avec confirmation"
        case .limitedAutomatic: "Automatisation limitée"
        }
    }
}

struct AutonomyRule: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var detail: String
    var level: AutonomyLevel
    var enabled: Bool
    var alwaysRequiresConfirmation: Bool

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        level: AutonomyLevel,
        enabled: Bool,
        alwaysRequiresConfirmation: Bool
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.level = level
        self.enabled = enabled
        self.alwaysRequiresConfirmation = alwaysRequiresConfirmation
    }
}

struct DraftPreview: Identifiable, Codable, Hashable {
    let id: UUID
    var sourceSignalID: UUID
    var recipient: String
    var subject: String
    var body: String
    var createdAt: Date?

    init(
        id: UUID = UUID(),
        sourceSignalID: UUID,
        recipient: String,
        subject: String,
        body: String,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.sourceSignalID = sourceSignalID
        self.recipient = recipient
        self.subject = subject
        self.body = body
        self.createdAt = createdAt
    }
}
