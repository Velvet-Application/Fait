import SwiftUI
import UniformTypeIdentifiers

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0

    private let pages = [
        (
            icon: "checkmark.seal.fill",
            title: "Vous demandez.\nC’est fait.",
            detail: "Confiez un courrier ou une démarche. FAIT. transforme le sujet en actions simples et suivies."
        ),
        (
            icon: "doc.text.magnifyingglass",
            title: "Comprendre avant d’agir",
            detail: "Chaque information extraite reste visible, modifiable et reliée à sa source."
        ),
        (
            icon: "hand.raised.fill",
            title: "Vous gardez le contrôle",
            detail: "Aucune action engageante n’est réalisée sans une validation explicite de votre part."
        )
    ]

    var body: some View {
        ZStack {
            FAITColor.warmWhite.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    TrustSeal(size: 42)
                    Text("FAIT.")
                        .font(.title2.bold())
                        .foregroundStyle(FAITColor.oliveCharcoal)
                    Spacer()
                }
                .padding(.horizontal, 24)

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, pageContent in
                        VStack(spacing: 28) {
                            Image(systemName: pageContent.icon)
                                .font(.system(size: 62, weight: .medium))
                                .foregroundStyle(FAITColor.trustGreen)
                                .frame(width: 128, height: 128)
                                .background(FAITColor.softSage.opacity(0.26), in: Circle())

                            Text(pageContent.title)
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)
                                .foregroundStyle(FAITColor.oliveCharcoal)

                            Text(pageContent.detail)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                        }
                        .padding(.horizontal, 28)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(page == pages.count - 1 ? "Commencer" : "Continuer")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }
}

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        TabView(selection: $environment.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Accueil", systemImage: "house") }
            .tag(AppTab.home)

            NavigationStack {
                CasesView()
            }
            .tabItem { Label("Dossiers", systemImage: "folder") }
            .tag(AppTab.cases)

            IntakeView()
                .tabItem { Label("Confier", systemImage: "plus.circle.fill") }
                .tag(AppTab.intake)

            NavigationStack {
                NotificationsView()
            }
            .tabItem { Label("Notifications", systemImage: "bell") }
            .tag(AppTab.notifications)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profil", systemImage: "person.crop.circle") }
            .tag(AppTab.profile)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var environment: AppEnvironment

    private var needsUser: [FAITCase] {
        environment.cases.filter { $0.status == .needsUser }
    }

    private var active: [FAITCase] {
        environment.cases.filter { $0.status == .inProgress || $0.status == .toDo }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 10) {
                    TrustSeal(size: 38)
                    Text("FAIT.")
                        .font(.title2.bold())
                        .foregroundStyle(FAITColor.oliveCharcoal)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bonjour Cyril")
                        .font(.largeTitle.bold())
                        .foregroundStyle(FAITColor.oliveCharcoal)
                    Text("Voici ce qui mérite votre attention.")
                        .foregroundStyle(.secondary)
                }

                Button {
                    environment.selectedTab = .intake
                } label: {
                    Label("Confier quelque chose", systemImage: "plus")
                }
                .buttonStyle(PrimaryActionButtonStyle())

                if environment.simulatedOffline {
                    Label(
                        "Mode hors ligne simulé — aucune action sensible ne peut être validée.",
                        systemImage: "wifi.slash"
                    )
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: 0x76591F))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(FAITColor.toDoBackground, in: RoundedRectangle(cornerRadius: 16))
                }

                if !needsUser.isEmpty {
                    SectionTitle(title: "Besoin de vous") {
                        environment.selectedTab = .cases
                    }
                    ForEach(needsUser.prefix(2)) { item in
                        NavigationLink(value: item) {
                            CaseCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !active.isEmpty {
                    SectionTitle(title: "En cours") {
                        environment.selectedTab = .cases
                    }
                    ForEach(active.prefix(3)) { item in
                        NavigationLink(value: item) {
                            CaseCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background(FAITColor.warmWhite)
        .navigationDestination(for: FAITCase.self) { item in
            CaseDetailView(caseID: item.id)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    environment.simulatedOffline.toggle()
                } label: {
                    Image(systemName: environment.simulatedOffline ? "wifi.slash" : "wifi")
                }
                .accessibilityLabel("Basculer le mode hors ligne simulé")
            }
        }
    }
}

private enum CaseFilter: String, CaseIterable, Identifiable {
    case all = "Tous"
    case active = "En cours"
    case done = "Terminés"

    var id: Self { self }
}

struct CasesView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var selection: CaseFilter = .all
    @State private var query = ""

    private var filtered: [FAITCase] {
        environment.cases.filter { item in
            let matchesFilter: Bool
            switch selection {
            case .all:
                matchesFilter = true
            case .active:
                matchesFilter = item.status != .done
            case .done:
                matchesFilter = item.status == .done
            }

            let matchesQuery = query.isEmpty
                || item.title.localizedCaseInsensitiveContains(query)
                || item.organization.localizedCaseInsensitiveContains(query)
            return matchesFilter && matchesQuery
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                Picker("Filtrer les dossiers", selection: $selection) {
                    ForEach(CaseFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                if filtered.isEmpty {
                    ContentUnavailableView(
                        "Aucun dossier",
                        systemImage: "folder",
                        description: Text("Modifiez les filtres ou confiez un nouveau sujet.")
                    )
                    .padding(.top, 80)
                } else {
                    ForEach(filtered) { item in
                        NavigationLink(value: item) {
                            CaseCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background(FAITColor.warmWhite)
        .navigationTitle("Dossiers")
        .searchable(text: $query, prompt: "Titre ou organisme")
        .navigationDestination(for: FAITCase.self) { item in
            CaseDetailView(caseID: item.id)
        }
    }
}

struct IntakeView: View {
    @State private var path: [DemoRoute] = []
    @State private var isImporterPresented = false
    @State private var importMessage: String?

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Confier quelque chose")
                        .font(.largeTitle.bold())
                        .foregroundStyle(FAITColor.oliveCharcoal)

                    Text("Choisissez le moyen le plus simple. Pour cette V0, le traitement reste entièrement simulé.")
                        .foregroundStyle(.secondary)

                    intakeButton(
                        title: "Courrier de démonstration",
                        detail: "Lancer immédiatement le parcours complet",
                        icon: "doc.text.magnifyingglass"
                    ) {
                        path.append(.analysis)
                    }

                    intakeButton(
                        title: "Importer un document",
                        detail: "PDF ou image via le sélecteur iOS",
                        icon: "square.and.arrow.down"
                    ) {
                        isImporterPresented = true
                    }

                    intakeButton(
                        title: "Prendre une photo",
                        detail: "Autorisation demandée seulement au moment de l’usage",
                        icon: "camera"
                    ) {
                        importMessage = "La capture réelle sera activée dans le prochain lot. Utilisez le courrier de démonstration."
                    }

                    intakeButton(
                        title: "Écrire une demande",
                        detail: "Décrire librement le sujet",
                        icon: "square.and.pencil"
                    ) {
                        importMessage = "La saisie libre sera ajoutée après validation du parcours courrier."
                    }

                    if let importMessage {
                        Text(importMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.background, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(20)
            }
            .background(FAITColor.warmWhite)
            .navigationDestination(for: DemoRoute.self) { route in
                switch route {
                case .analysis:
                    AnalysisDemoView(path: $path)
                case .actionPlan(let analysis):
                    ActionPlanDemoView(analysis: analysis, path: $path)
                case .sensitiveValidation(let analysis):
                    SensitiveValidationDemoView(analysis: analysis, path: $path)
                case .completion(let caseID):
                    CompletionDemoView(caseID: caseID)
                }
            }
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.pdf, .image],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success:
                    importMessage = "Document sélectionné. Pour protéger vos données, cette V0 ne le conserve pas et lance le scénario fictif."
                    path.append(.analysis)
                case .failure(let error):
                    importMessage = error.localizedDescription
                }
            }
        }
    }

    private func intakeButton(
        title: String,
        detail: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(FAITColor.trustGreen)
                    .frame(width: 48, height: 48)
                    .background(FAITColor.softSage.opacity(0.28), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(FAITColor.oliveCharcoal)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

struct AnalysisDemoView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Binding var path: [DemoRoute]

    @State private var analysis: DocumentAnalysis?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var dueDate = Date.now

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 18) {
                    ProgressView()
                    Text("FAIT. analyse le courrier…")
                        .font(.headline)
                    Text("Traitement simulé, aucune donnée n’est transmise.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage {
                ContentUnavailableView(
                    "Analyse impossible",
                    systemImage: "doc.badge.exclamationmark",
                    description: Text(errorMessage)
                )
            } else if let analysis {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                StatusBadge(status: .toDo)
                                Spacer()
                                Text("\(Int(analysis.confidence * 100)) % compris")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            Text(analysis.title)
                                .font(.title2.bold())
                                .foregroundStyle(FAITColor.oliveCharcoal)
                            Text(analysis.summary)
                                .foregroundStyle(.secondary)
                        }
                        .padding(18)
                        .background(.background, in: RoundedRectangle(cornerRadius: 20))

                        extractedField("Organisme", value: analysis.organization, source: "En-tête du courrier")
                        extractedField("Personne concernée", value: analysis.person, source: "Référence destinataire")

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Date limite")
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Label("À vérifier", systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color(hex: 0x8A4E24))
                            }
                            DatePicker("Date limite", selection: $dueDate, displayedComponents: .date)
                                .labelsHidden()
                            Text("Source : paragraphe 2 — confiance moyenne")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .background(FAITColor.needsUserBackground.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))

                        Button("Continuer vers le plan d’action") {
                            var corrected = analysis
                            corrected.dueDate = dueDate
                            path.append(.actionPlan(corrected))
                        }
                        .buttonStyle(PrimaryActionButtonStyle())
                    }
                    .padding(20)
                }
            }
        }
        .background(FAITColor.warmWhite)
        .navigationTitle("Analyse")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard analysis == nil else { return }
            do {
                if environment.simulatedOffline {
                    throw DemoServiceError.simulatedOffline
                }
                let result = try await environment.analyzer.analyzeDemoLetter()
                analysis = result
                dueDate = result.dueDate
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func extractedField(_ label: String, value: String, source: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body.weight(.medium))
            Label("Source : \(source)", systemImage: "doc.text")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ActionPlanDemoView: View {
    @EnvironmentObject private var environment: AppEnvironment
    let analysis: DocumentAnalysis
    @Binding var path: [DemoRoute]

    @State private var steps: [CaseStep] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Voici le plan proposé")
                    .font(.title2.bold())
                    .foregroundStyle(FAITColor.oliveCharcoal)
                Text("Chaque étape indique clairement qui agit et si votre accord est nécessaire.")
                    .foregroundStyle(.secondary)

                if isLoading {
                    ProgressView("Préparation du plan…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                } else if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                } else {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .top, spacing: 14) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(FAITColor.trustGreen, in: Circle())

                            VStack(alignment: .leading, spacing: 5) {
                                Text(step.title)
                                    .font(.headline)
                                Text(step.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Responsable : \(step.owner)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(FAITColor.trustGreen)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(.background, in: RoundedRectangle(cornerRadius: 18))
                    }

                    Button("Accepter le plan") {
                        path.append(.sensitiveValidation(analysis))
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                }
            }
            .padding(20)
        }
        .background(FAITColor.warmWhite)
        .navigationTitle("Plan d’action")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard steps.isEmpty else { return }
            do {
                steps = try await environment.actionPlanProvider.steps(for: analysis)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct SensitiveValidationDemoView: View {
    @EnvironmentObject private var environment: AppEnvironment
    let analysis: DocumentAnalysis
    @Binding var path: [DemoRoute]

    @State private var hasReviewed = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Label("Votre accord est nécessaire", systemImage: "hand.raised.fill")
                    .font(.title2.bold())
                    .foregroundStyle(FAITColor.oliveCharcoal)

                Text("Cette démonstration simule la préparation d’une réponse. Aucun message ne sera réellement envoyé.")
                    .foregroundStyle(.secondary)

                validationRow("Destinataire", value: analysis.organization)
                validationRow("Objet", value: analysis.title)
                validationRow("Date limite", value: analysis.dueDate.formatted(date: .long, time: .omitted))
                validationRow("Pièce jointe", value: "Justificatif de domicile fictif.pdf")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Message préparé")
                        .font(.subheadline.weight(.semibold))
                    Text("Bonjour,\n\nVeuillez trouver ci-joint le justificatif demandé pour la poursuite de mon dossier.\n\nCordialement.")
                        .textSelection(.enabled)
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 18))

                Toggle(
                    "J’ai vérifié le destinataire, le contenu et la pièce jointe.",
                    isOn: $hasReviewed
                )
                .font(.subheadline)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                Button {
                    submit()
                } label: {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Valider l’action simulée")
                    }
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .disabled(!hasReviewed || isSubmitting)
                .opacity(hasReviewed ? 1 : 0.5)

                Text("Une modification du destinataire, du texte, des pièces ou de la date imposerait une nouvelle validation.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .background(FAITColor.warmWhite)
        .navigationTitle("Validation")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func validationRow(_ label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
    }

    private func submit() {
        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                if environment.simulatedOffline {
                    throw DemoServiceError.simulatedOffline
                }
                try await environment.validationService.validate(analysis: analysis)
                let steps = try await environment.actionPlanProvider.steps(for: analysis)
                let caseID = environment.addDemoCase(analysis: analysis, steps: steps)
                environment.markCaseDone(id: caseID)
                path.append(.completion(caseID))
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}

struct CompletionDemoView: View {
    @EnvironmentObject private var environment: AppEnvironment
    let caseID: UUID

    private var item: FAITCase? {
        environment.cases.first(where: { $0.id == caseID })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                TrustSeal(size: 96)

                VStack(spacing: 8) {
                    Text("C’est fait.")
                        .font(.largeTitle.bold())
                        .foregroundStyle(FAITColor.oliveCharcoal)
                    Text("L’action simulée est terminée et sa preuve est disponible.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let item {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusBadge(status: item.status)
                        Text(item.title)
                            .font(.title3.bold())
                        Label(item.proofTitle ?? "Preuve locale", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(FAITColor.trustGreen)
                        Text("Créée \(item.updatedAt.formatted(date: .long, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.background, in: RoundedRectangle(cornerRadius: 20))
                }

                Button("Retrouver le dossier") {
                    environment.selectedTab = .cases
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .padding(24)
        }
        .background(FAITColor.warmWhite)
        .navigationBarBackButtonHidden()
    }
}

struct CaseDetailView: View {
    @EnvironmentObject private var environment: AppEnvironment
    let caseID: UUID

    private var item: FAITCase? {
        environment.cases.first(where: { $0.id == caseID })
    }

    var body: some View {
        ScrollView {
            if let item {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        StatusBadge(status: item.status)
                        Spacer()
                        Text(item.person)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(item.summary)
                        .font(.title3)
                        .foregroundStyle(FAITColor.oliveCharcoal)

                    detailSection("Prochaine action") {
                        Label(item.nextAction, systemImage: "arrow.right.circle.fill")
                            .foregroundStyle(FAITColor.trustGreen)
                            .fontWeight(.semibold)
                    }

                    if !item.steps.isEmpty {
                        detailSection("Étapes") {
                            VStack(spacing: 14) {
                                ForEach(item.steps) { step in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: step.state == .completed ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(step.state == .completed ? FAITColor.trustGreen : .secondary)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(step.title).fontWeight(.semibold)
                                            Text(step.detail)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }

                    detailSection("Historique") {
                        VStack(spacing: 14) {
                            ForEach(item.events.sorted(by: { $0.date > $1.date })) { event in
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(FAITColor.softSage)
                                        .frame(width: 10, height: 10)
                                        .padding(.top, 5)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(event.title).fontWeight(.semibold)
                                        Text(event.detail)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Text(event.date, format: .dateTime.day().month().hour().minute())
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    if let proof = item.proofTitle {
                        detailSection("Preuve") {
                            Label(proof, systemImage: "checkmark.seal.fill")
                                .foregroundStyle(FAITColor.trustGreen)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(20)
            } else {
                ContentUnavailableView("Dossier introuvable", systemImage: "folder.badge.questionmark")
                    .padding(.top, 80)
            }
        }
        .background(FAITColor.warmWhite)
        .navigationTitle(item?.title ?? "Dossier")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title3.bold())
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct NotificationsView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        List(environment.notices) { notice in
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: notice.status.systemImage)
                    .foregroundStyle(FAITColor.trustGreen)
                    .frame(width: 36, height: 36)
                    .background(FAITColor.softSage.opacity(0.26), in: Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text(notice.title).font(.headline)
                    Text(notice.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(notice.date, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 6)
        }
        .scrollContentBackground(.hidden)
        .background(FAITColor.warmWhite)
        .navigationTitle("Notifications")
    }
}

struct ProfileView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @AppStorage("fait.hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    TrustSeal(size: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Cyril").font(.headline)
                        Text("Compte de démonstration")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Foyer") {
                Label("Membres du foyer", systemImage: "person.2")
                Label("Logements", systemImage: "house")
                Label("Véhicules", systemImage: "car")
                Label("Documents réutilisables", systemImage: "doc.on.doc")
            }

            Section("Sécurité") {
                Label("Face ID — à connecter", systemImage: "faceid")
                Label("Appareils connectés", systemImage: "iphone")
                Label("Export et suppression", systemImage: "arrow.down.doc")
            }

            Section("Prototype") {
                Toggle("Simuler l’absence de réseau", isOn: $environment.simulatedOffline)
                Button("Revoir l’onboarding") {
                    hasCompletedOnboarding = false
                }
            }

            Section {
                Text("Aucune donnée réelle n’est stockée ou transmise dans cette V0.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(FAITColor.warmWhite)
        .navigationTitle("Profil")
    }
}
