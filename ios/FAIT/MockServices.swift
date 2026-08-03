import Foundation

protocol DocumentAnalyzing {
    func analyzeDemoLetter() async throws -> DocumentAnalysis
}

protocol ActionPlanProviding {
    func steps(for analysis: DocumentAnalysis) async throws -> [CaseStep]
}

protocol SensitiveActionValidating {
    func validate(analysis: DocumentAnalysis) async throws
}

enum DemoServiceError: LocalizedError {
    case unreadableDocument
    case simulatedOffline

    var errorDescription: String? {
        switch self {
        case .unreadableDocument:
            "Le document est trop flou pour être analysé."
        case .simulatedOffline:
            "La connexion est indisponible. Réessayez lorsque le réseau revient."
        }
    }
}

struct MockDocumentAnalyzer: DocumentAnalyzing {
    func analyzeDemoLetter() async throws -> DocumentAnalysis {
        try await Task.sleep(for: .milliseconds(850))

        return DocumentAnalysis(
            title: "Demande de justificatif",
            organization: "Caisse d’allocations familiales",
            person: "Cyril",
            summary: "La CAF demande un justificatif de domicile récent afin de poursuivre l’étude du dossier.",
            dueDate: Calendar.current.date(byAdding: .day, value: 12, to: .now) ?? .now,
            amount: nil,
            confidence: 0.92,
            uncertainFields: ["dueDate"]
        )
    }
}

struct MockActionPlanProvider: ActionPlanProviding {
    func steps(for analysis: DocumentAnalysis) async throws -> [CaseStep] {
        try await Task.sleep(for: .milliseconds(450))

        return [
            CaseStep(
                title: "Vérifier la date limite",
                detail: "La date a été extraite avec une confiance moyenne.",
                state: .current,
                owner: "Vous"
            ),
            CaseStep(
                title: "Ajouter un justificatif",
                detail: "Facture d’énergie ou quittance de loyer de moins de trois mois.",
                state: .upcoming,
                owner: "Vous"
            ),
            CaseStep(
                title: "Préparer la réponse",
                detail: "FAIT. prépare un message et vérifie les pièces.",
                state: .upcoming,
                owner: "FAIT."
            ),
            CaseStep(
                title: "Valider l’envoi simulé",
                detail: "Aucune action n’est engagée sans votre accord.",
                state: .upcoming,
                owner: "Vous"
            )
        ]
    }
}

struct MockValidationService: SensitiveActionValidating {
    func validate(analysis: DocumentAnalysis) async throws {
        try await Task.sleep(for: .milliseconds(650))
    }
}

@MainActor
final class AppEnvironment: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var cases: [FAITCase]
    @Published var notices: [AppNotice]
    @Published var simulatedOffline = false

    let analyzer: DocumentAnalyzing
    let actionPlanProvider: ActionPlanProviding
    let validationService: SensitiveActionValidating

    init(
        analyzer: DocumentAnalyzing = MockDocumentAnalyzer(),
        actionPlanProvider: ActionPlanProviding = MockActionPlanProvider(),
        validationService: SensitiveActionValidating = MockValidationService()
    ) {
        self.analyzer = analyzer
        self.actionPlanProvider = actionPlanProvider
        self.validationService = validationService

        let seededCases = DemoFixtures.cases
        self.cases = seededCases
        self.notices = [
            AppNotice(
                title: "Votre validation est requise",
                detail: "Le dossier « Résiliation Internet » attend votre accord.",
                status: .needsUser,
                caseID: seededCases.first(where: { $0.status == .needsUser })?.id
            ),
            AppNotice(
                title: "Échéance dans 12 jours",
                detail: "Un justificatif doit être transmis à la CAF.",
                date: Calendar.current.date(byAdding: .hour, value: -4, to: .now) ?? .now,
                status: .toDo,
                caseID: seededCases.first?.id
            )
        ]
    }

    func addDemoCase(analysis: DocumentAnalysis, steps: [CaseStep]) -> UUID {
        let item = FAITCase(
            title: analysis.title,
            organization: analysis.organization,
            person: analysis.person,
            summary: analysis.summary,
            status: .needsUser,
            nextAction: "Valider la réponse préparée",
            dueDate: analysis.dueDate,
            amount: analysis.amount,
            steps: steps,
            events: [
                CaseEvent(
                    title: "Document importé",
                    detail: "Courrier de démonstration ajouté.",
                    date: .now
                ),
                CaseEvent(
                    title: "Analyse terminée",
                    detail: "Les informations importantes ont été extraites.",
                    date: .now
                )
            ]
        )
        cases.insert(item, at: 0)
        return item.id
    }

    func markCaseDone(id: UUID) {
        guard let index = cases.firstIndex(where: { $0.id == id }) else { return }
        cases[index].status = .done
        cases[index].nextAction = "Aucune action requise"
        cases[index].proofTitle = "Confirmation d’envoi simulée"
        cases[index].updatedAt = .now
        cases[index].events.append(
            CaseEvent(
                title: "Dossier finalisé",
                detail: "La démonstration a généré une preuve locale.",
                date: .now
            )
        )
        notices.insert(
            AppNotice(
                title: "Dossier terminé",
                detail: "La preuve de résolution est disponible.",
                status: .done,
                caseID: id
            ),
            at: 0
        )
    }
}

enum DemoFixtures {
    static let cases: [FAITCase] = {
        let today = Date.now
        return [
            FAITCase(
                title: "Justificatif CAF",
                organization: "CAF",
                person: "Cyril",
                summary: "Un justificatif de domicile doit être transmis.",
                status: .toDo,
                nextAction: "Vérifier la date limite",
                dueDate: Calendar.current.date(byAdding: .day, value: 12, to: today),
                updatedAt: Calendar.current.date(byAdding: .hour, value: -2, to: today) ?? today,
                steps: [
                    CaseStep(
                        title: "Vérifier la demande",
                        detail: "Contrôler les informations extraites.",
                        state: .current,
                        owner: "Vous"
                    ),
                    CaseStep(
                        title: "Ajouter le justificatif",
                        detail: "Joindre une facture récente.",
                        state: .upcoming,
                        owner: "Vous"
                    )
                ],
                events: [
                    CaseEvent(
                        title: "Courrier reçu",
                        detail: "Document de démonstration importé.",
                        date: Calendar.current.date(byAdding: .hour, value: -2, to: today) ?? today
                    )
                ]
            ),
            FAITCase(
                title: "Résiliation Internet",
                organization: "Opérateur Démo",
                person: "Foyer",
                summary: "Une demande de résiliation est prête à être validée.",
                status: .needsUser,
                nextAction: "Valider le courrier",
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: today),
                updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
            ),
            FAITCase(
                title: "Contrôle technique",
                organization: "Véhicule familial",
                person: "Cyril",
                summary: "Le prochain contrôle a été programmé.",
                status: .inProgress,
                nextAction: "Attendre le rendez-vous",
                dueDate: Calendar.current.date(byAdding: .day, value: 28, to: today),
                updatedAt: Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today
            ),
            FAITCase(
                title: "Carte d’identité",
                organization: "Mairie",
                person: "Inès",
                summary: "Le renouvellement est terminé.",
                status: .done,
                nextAction: "Aucune action requise",
                dueDate: nil,
                updatedAt: Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today,
                proofTitle: "Confirmation de retrait"
            )
        ]
    }()
}
