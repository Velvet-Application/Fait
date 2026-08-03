import Foundation
import SwiftUI

enum AppTab: Hashable {
    case home
    case cases
    case intake
    case notifications
    case profile
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
        proofTitle: String? = nil
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
    }
}

struct DocumentAnalysis: Hashable {
    var title: String
    var organization: String
    var person: String
    var summary: String
    var dueDate: Date
    var amount: Decimal?
    var confidence: Double
    var uncertainFields: Set<String>
}

struct AppNotice: Identifiable, Hashable {
    let id: UUID
    var title: String
    var detail: String
    var date: Date
    var status: CaseStatus
    var caseID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        date: Date = .now,
        status: CaseStatus,
        caseID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.date = date
        self.status = status
        self.caseID = caseID
    }
}

enum DemoRoute: Hashable {
    case analysis
    case actionPlan(DocumentAnalysis)
    case sensitiveValidation(DocumentAnalysis)
    case completion(UUID)
}
