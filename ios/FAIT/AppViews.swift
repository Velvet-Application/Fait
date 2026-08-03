import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0

    private let pages = [
        (
            icon: "sparkles",
            title: "FAIT. repère ce qui compte.",
            detail: "Factures, rendez-vous, contrats et démarches deviennent des actions claires."
        ),
        (
            icon: "calendar.badge.clock",
            title: "Votre quotidien s’organise.",
            detail: "FAIT. prépare les dossiers, l’agenda et les rappels sans vous faire tout ressaisir."
        ),
        (
            icon: "hand.raised.fill",
            title: "Vous gardez la décision.",
            detail: "Les envois, réservations et actions engageantes restent soumis à votre accord."
        )
    ]

    var body: some View {
        ZStack {
            FAITBackground()

            VStack(spacing: 22) {
                HStack {
                    BrandLockup(compact: true)
                    Spacer()
                    Text("DÉMO iOS")
                        .font(.caption2.bold())
                        .tracking(1)
                        .foregroundStyle(FAITColor.trustGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(FAITColor.softSage.opacity(0.24), in: Capsule())
                }
                .padding(.horizontal, 22)

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        VStack(spacing: 28) {
                            Image(systemName: item.icon)
                                .font(.system(size: 54, weight: .medium))
                                .foregroundStyle(FAITColor.trustGreen)
                                .frame(width: 126, height: 126)
                                .background(FAITColor.softSage.opacity(0.22), in: Circle())

                            VStack(spacing: 14) {
                                Text(item.title)
                                    .font(.system(size: 35, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(FAITColor.oliveCharcoal)

                                Text(item.detail)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                            }
                        }
                        .padding(.horizontal, 28)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button {
                    if page < pages.count - 1 {
                        withAnimation(.snappy) { page += 1 }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(page == pages.count - 1 ? "Découvrir FAIT." : "Continuer")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.horizontal, 22)
                .padding(.bottom, 10)
            }
        }
    }
}

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        ZStack {
            FAITBackground()

            Group {
                switch environment.selectedTab {
                case .home:
                    NavigationStack { HomeView() }
                case .cases:
                    NavigationStack { CasesView() }
                case .intake:
                    NavigationStack { IntakeView() }
                case .detected:
                    NavigationStack { DetectedView() }
                case .profile:
                    NavigationStack { ProfileView() }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FloatingDock()
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
        }
        .overlay(alignment: .top) {
            if let message = environment.toastMessage {
                ToastView(message: message)
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: environment.toastMessage)
    }
}

struct FAITBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [FAITColor.warmWhite, FAITColor.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [FAITColor.softSage.opacity(0.20), .clear],
                center: .topLeading,
                startRadius: 10,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}

struct FloatingDock: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        HStack(spacing: 2) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.28)) {
                        environment.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab == .intake ? "plus" : tab.systemImage)
                                .font(.system(size: tab == .intake ? 22 : 18, weight: .semibold))
                                .frame(width: tab == .intake ? 48 : 34, height: tab == .intake ? 48 : 34)
                                .foregroundStyle(tab == .intake ? .white : color(for: tab))
                                .background {
                                    if tab == .intake {
                                        Circle()
                                            .fill(FAITColor.trustGreen)
                                            .shadow(color: FAITColor.deepGreen.opacity(0.22), radius: 12, y: 6)
                                    } else if environment.selectedTab == tab {
                                        Circle().fill(FAITColor.softSage.opacity(0.26))
                                    }
                                }

                            if tab == .detected && environment.pendingConfirmationCount > 0 {
                                Text("\(environment.pendingConfirmationCount)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 17, minHeight: 17)
                                    .background(Color.orange, in: Circle())
                                    .offset(x: 3, y: -2)
                            }
                        }

                        Text(tab.title)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(color(for: tab))
                    }
                    .frame(maxWidth: .infinity)
                    .offset(y: tab == .intake ? -9 : 0)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 5)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.78), lineWidth: 1)
        }
        .shadow(color: FAITColor.deepGreen.opacity(0.12), radius: 22, y: 10)
    }

    private func color(for tab: AppTab) -> Color {
        environment.selectedTab == tab || tab == .intake ? FAITColor.trustGreen : FAITColor.mutedText
    }
}

struct HomeView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var selectedSignal: ConnectedSignal?

    private var attentionSignal: ConnectedSignal? {
        environment.signals.first(where: { $0.state == .needsConfirmation })
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                PageBrandHeader(
                    statusText: environment.pendingConfirmationCount > 0
                        ? "\(environment.pendingConfirmationCount) décisions attendent votre accord"
                        : "Tout est sous contrôle"
                )

                HeroCard {
                    environment.selectedTab = .intake
                }

                if let attentionSignal {
                    SectionTitle(eyebrow: "À vous de jouer", title: "Une décision vous attend")
                    AttentionCard(signal: attentionSignal) {
                        selectedSignal = attentionSignal
                    }
                }

                SectionTitle(eyebrow: "Repéré pour vous", title: "Ce qui mérite votre attention") {
                    environment.selectedTab = .detected
                }

                ForEach(environment.signals.prefix(3)) { signal in
                    SignalCard(signal: signal) {
                        selectedSignal = signal
                    }
                }

                SectionTitle(eyebrow: "À venir", title: "Votre agenda FAIT.") {
                    environment.selectedTab = .cases
                }

                VStack(spacing: 10) {
                    ForEach(environment.agendaEvents.prefix(3)) { event in
                        AgendaRow(event: event)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedSignal) { signal in
            SignalActionSheet(signalID: signal.id)
                .environmentObject(environment)
        }
    }
}

struct PageBrandHeader: View {
    let statusText: String

    var body: some View {
        HStack(spacing: 12) {
            BrandLockup(compact: true)
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 7, height: 7)
                    Text("ENVIRONNEMENT TEST")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                }
                .foregroundStyle(FAITColor.trustGreen)
                Text(statusText)
                    .font(.caption2)
                    .foregroundStyle(FAITColor.mutedText)
                    .lineLimit(1)
            }
        }
    }
}

struct HeroCard: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Bonjour Cyril")
                .font(.caption.bold())
                .tracking(1.1)
                .foregroundStyle(FAITColor.trustGreen)

            Text("Dites-nous ce qui vous encombre.")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(FAITColor.oliveCharcoal)
                .fixedSize(horizontal: false, vertical: true)

            Text("Un courrier, un contrat, une échéance. FAIT. transforme le sujet en étapes claires jusqu’à sa résolution.")
                .font(.body)
                .foregroundStyle(FAITColor.mutedText)
                .lineSpacing(4)

            Button(action: action) {
                HStack(spacing: 14) {
                    Image(systemName: "plus")
                        .font(.title3.bold())
                        .frame(width: 48, height: 48)
                        .background(FAITColor.trustGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Confier quelque chose")
                            .font(.headline)
                            .foregroundStyle(FAITColor.oliveCharcoal)
                        Text("Photo, document, e-mail, texte ou dictée")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(FAITColor.trustGreen)
                }
                .padding(12)
                .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [.white.opacity(0.86), FAITColor.softSage.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.9), lineWidth: 1)
        }
        .shadow(color: FAITColor.deepGreen.opacity(0.09), radius: 28, y: 14)
    }
}

struct AttentionCard: View {
    let signal: ConnectedSignal
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label(signal.kind.rawValue, systemImage: signal.kind.systemImage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.72))
                    Spacer()
                    SignalStateBadge(state: signal.state)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(signal.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(signal.summary)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.68))
                        .multilineTextAlignment(.leading)
                }

                HStack {
                    Text(signal.suggestedAction)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(FAITColor.deepGreen)
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(21)
            .background(
                LinearGradient(
                    colors: [FAITColor.trustGreen, FAITColor.deepGreen],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .shadow(color: FAITColor.deepGreen.opacity(0.20), radius: 24, y: 12)
        }
        .buttonStyle(.plain)
    }
}

struct SignalCard: View {
    let signal: ConnectedSignal
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: signal.kind.systemImage)
                        .font(.title3)
                        .foregroundStyle(FAITColor.trustGreen)
                        .frame(width: 44, height: 44)
                        .background(FAITColor.softSage.opacity(0.24), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(signal.title)
                            .font(.headline)
                            .foregroundStyle(FAITColor.oliveCharcoal)
                            .multilineTextAlignment(.leading)
                        Text(signal.source)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 4)
                    SignalStateBadge(state: signal.state)
                }

                Text(signal.summary)
                    .font(.subheadline)
                    .foregroundStyle(FAITColor.mutedText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                HStack {
                    Text("\(Int(signal.confidence * 100)) % de confiance")
                    Spacer()
                    Text(signal.suggestedAction)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                }
                .font(.caption)
                .foregroundStyle(FAITColor.trustGreen)
            }
            .padding(17)
            .glassCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
    }
}

struct DetectedView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var selectedSignal: ConnectedSignal?
    @State private var filter: SignalFilter = .all

    var filteredSignals: [ConnectedSignal] {
        environment.signals.filter { signal in
            switch filter {
            case .all: true
            case .confirmation: signal.state == .needsConfirmation
            case .prepared: signal.state == .prepared || signal.state == .synchronized
            }
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                PageTitle(
                    eyebrow: "Boîte intelligente",
                    title: "FAIT. a repéré ceci.",
                    detail: "Chaque information reste liée à sa source. Rien n’est envoyé ou réservé sans le niveau d’accord prévu."
                )

                Picker("Filtre", selection: $filter) {
                    ForEach(SignalFilter.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                if filteredSignals.isEmpty {
                    ContentUnavailableView(
                        "Rien à afficher",
                        systemImage: "sparkles",
                        description: Text("Les prochains éléments utiles apparaîtront ici.")
                    )
                    .padding(.top, 60)
                } else {
                    ForEach(filteredSignals) { signal in
                        SignalCard(signal: signal) {
                            selectedSignal = signal
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedSignal) { signal in
            SignalActionSheet(signalID: signal.id)
                .environmentObject(environment)
        }
    }
}

private enum SignalFilter: String, CaseIterable, Identifiable {
    case all
    case confirmation
    case prepared

    var id: Self { self }
    var title: String {
        switch self {
        case .all: "Tous"
        case .confirmation: "À confirmer"
        case .prepared: "Préparés"
        }
    }
}

struct CasesView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var mode: CasesMode = .cases
    @State private var selectedCase: FAITCase?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                PageTitle(
                    eyebrow: "Votre mémoire quotidienne",
                    title: "Dossiers et agenda.",
                    detail: "Les documents, décisions, rendez-vous et preuves restent réunis au même endroit."
                )

                Picker("Contenu", selection: $mode) {
                    ForEach(CasesMode.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                switch mode {
                case .cases:
                    ForEach(environment.cases) { item in
                        Button {
                            selectedCase = item
                        } label: {
                            CaseCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                case .agenda:
                    if environment.agendaEvents.isEmpty {
                        ContentUnavailableView("Agenda vide", systemImage: "calendar")
                            .padding(.top, 60)
                    } else {
                        ForEach(environment.agendaEvents) { event in
                            AgendaRow(event: event)
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedCase) { item in
            CaseDetailSheet(caseID: item.id)
                .environmentObject(environment)
        }
    }
}

private enum CasesMode: String, CaseIterable, Identifiable {
    case cases
    case agenda

    var id: Self { self }
    var title: String { self == .cases ? "Dossiers" : "Agenda" }
}

struct AgendaRow: View {
    let event: AgendaEvent

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(event.startDate, format: .dateTime.day())
                    .font(.title2.bold())
                    .foregroundStyle(FAITColor.deepGreen)
                Text(event.startDate, format: .dateTime.month(.abbreviated))
                    .font(.caption2.bold())
                    .textCase(.uppercase)
                    .foregroundStyle(FAITColor.trustGreen)
            }
            .frame(width: 52, height: 58)
            .background(FAITColor.softSage.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(FAITColor.oliveCharcoal)
                Text(event.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(event.startDate, format: .dateTime.hour().minute())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FAITColor.trustGreen)
            }
            Spacer()
            Image(systemName: event.syncedToDevice ? "iphone.gen3.circle.fill" : "calendar.circle")
                .foregroundStyle(event.syncedToDevice ? FAITColor.trustGreen : FAITColor.mutedText)
                .accessibilityLabel(event.syncedToDevice ? "Synchronisé avec l’iPhone" : "Agenda FAIT. uniquement")
        }
        .padding(15)
        .glassCard(cornerRadius: 21)
    }
}

struct IntakeView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var method: IntakeMethod?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                PageTitle(
                    eyebrow: "Un seul point de départ",
                    title: "Comment souhaitez-vous nous le confier ?",
                    detail: "Choisissez ce qui est le plus simple maintenant. FAIT. demandera seulement ce qui manque."
                )

                ForEach(IntakeMethod.allCases) { item in
                    Button {
                        method = item
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: item.systemImage)
                                .font(.title3)
                                .foregroundStyle(item == .camera ? .white : FAITColor.trustGreen)
                                .frame(width: 50, height: 50)
                                .background(
                                    item == .camera ? FAITColor.trustGreen : FAITColor.softSage.opacity(0.22),
                                    in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                                )
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundStyle(FAITColor.oliveCharcoal)
                                Text(item.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundStyle(FAITColor.trustGreen)
                        }
                        .padding(15)
                        .glassCard(cornerRadius: 22)
                    }
                    .buttonStyle(.plain)
                }

                Label {
                    Text("Rien ne part sans vous. Les actions engageantes exigent toujours le niveau de confirmation défini.")
                } icon: {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(FAITColor.trustGreen)
                }
                .font(.subheadline)
                .padding(16)
                .background(FAITColor.softSage.opacity(0.18), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $method) { item in
            ManualIntakeSheet(method: item)
                .environmentObject(environment)
        }
    }
}

private enum IntakeMethod: String, CaseIterable, Identifiable {
    case camera
    case document
    case email
    case text
    case voice

    var id: Self { self }
    var title: String {
        switch self {
        case .camera: "Prendre une photo"
        case .document: "Déposer un document"
        case .email: "Coller un e-mail"
        case .text: "Écrire la situation"
        case .voice: "La raconter"
        }
    }
    var detail: String {
        switch self {
        case .camera: "Un courrier posé devant vous"
        case .document: "PDF ou image depuis votre iPhone"
        case .email: "Un message reçu à comprendre ou traiter"
        case .text: "Quelques mots suffisent pour commencer"
        case .voice: "Dicter naturellement ce qui vous préoccupe"
        }
    }
    var systemImage: String {
        switch self {
        case .camera: "camera.fill"
        case .document: "doc.fill"
        case .email: "envelope.fill"
        case .text: "text.cursor"
        case .voice: "waveform"
        }
    }
}

struct ManualIntakeSheet: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    let method: IntakeMethod
    @State private var title = ""
    @State private var detail = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: method.systemImage)
                        .font(.largeTitle)
                        .foregroundStyle(FAITColor.trustGreen)
                        .frame(width: 72, height: 72)
                        .background(FAITColor.softSage.opacity(0.22), in: Circle())

                    Text(method.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(FAITColor.oliveCharcoal)

                    Text("Dans cette version synchronisée, l’entrée est simulée afin de tester le parcours sans transmettre de donnée.")
                        .foregroundStyle(.secondary)

                    TextField("Titre du sujet", text: $title)
                        .textFieldStyle(.roundedBorder)
                    TextField("Décrivez brièvement la situation", text: $detail, axis: .vertical)
                        .lineLimit(4...8)
                        .textFieldStyle(.roundedBorder)

                    Button("Créer le dossier de test") {
                        let item = FAITCase(
                            title: title.isEmpty ? "Nouveau sujet confié" : title,
                            organization: "Ajout manuel",
                            person: "Cyril",
                            summary: detail.isEmpty ? "Sujet créé depuis l’entrée \(method.title.lowercased())." : detail,
                            status: .toDo,
                            nextAction: "Préciser les informations manquantes",
                            dueDate: nil,
                            steps: [
                                CaseStep(title: "Comprendre la demande", detail: "Vérifier les informations fournies.", state: .current, owner: "FAIT."),
                                CaseStep(title: "Préparer la suite", detail: "Proposer les prochaines étapes.", state: .upcoming, owner: "FAIT.")
                            ],
                            events: [CaseEvent(title: "Sujet confié", detail: "Source : \(method.title)", date: .now)]
                        )
                        environment.cases.insert(item, at: 0)
                        environment.selectedTab = .cases
                        dismiss()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                }
                .padding(20)
            }
            .background(FAITColor.warmWhite)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }
}

struct ProfileView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var tab: ProfileTab = .connections

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                PageTitle(
                    eyebrow: "Votre espace",
                    title: "Connexions et autonomie.",
                    detail: "Vous voyez ce que FAIT. connaît, ce qu’il peut faire et ce qui exige toujours votre confirmation."
                )

                Picker("Profil", selection: $tab) {
                    ForEach(ProfileTab.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                switch tab {
                case .identity:
                    IdentityPanel()
                case .connections:
                    ConnectionsPanel()
                case .autonomy:
                    AutonomyPanel()
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private enum ProfileTab: String, CaseIterable, Identifiable {
    case identity
    case connections
    case autonomy

    var id: Self { self }
    var title: String {
        switch self {
        case .identity: "Profil"
        case .connections: "Connexions"
        case .autonomy: "Autonomie"
        }
    }
}

struct IdentityPanel: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 15) {
                Text("CG")
                    .font(.title2.bold())
                    .foregroundStyle(FAITColor.deepGreen)
                    .frame(width: 64, height: 64)
                    .background(FAITColor.softSage.opacity(0.30), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cyril Gay")
                        .font(.title3.bold())
                    Text("Compte principal · Hauts-de-France")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Label("Adresse e-mail vérifiée", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(FAITColor.trustGreen)
                }
                Spacer()
            }
            .padding(18)
            .glassCard(cornerRadius: 24)

            ProfileInfoCard(title: "Mon foyer", rows: ["Céline · Membre du foyer", "Inès · Enfant du foyer"])
            ProfileInfoCard(title: "Mes biens", rows: ["Logement principal", "Peugeot 3008 · Véhicule familial"])
            ProfileInfoCard(title: "Sécurité et données", rows: ["Exporter mes données", "Gérer les autorisations", "Supprimer mon compte"])
        }
    }
}

struct ConnectionsPanel: View {
    @EnvironmentObject private var environment: AppEnvironment
    @State private var connectionToRevoke: ExternalConnection?

    var body: some View {
        VStack(spacing: 14) {
            ForEach(environment.connections) { connection in
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 12) {
                        Image(systemName: connection.systemImage)
                            .font(.title3)
                            .foregroundStyle(FAITColor.trustGreen)
                            .frame(width: 46, height: 46)
                            .background(FAITColor.softSage.opacity(0.22), in: Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text(connection.service)
                                .font(.headline)
                            Text(connection.account)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        ConnectionStateBadge(state: connection.state)
                    }

                    Text(connection.automationSummary)
                        .font(.subheadline)
                        .foregroundStyle(FAITColor.mutedText)

                    if !connection.permissions.isEmpty {
                        VStack(alignment: .leading, spacing: 7) {
                            ForEach(connection.permissions, id: \.self) { permission in
                                Label(permission, systemImage: "checkmark")
                                    .font(.caption)
                                    .foregroundStyle(FAITColor.oliveCharcoal)
                            }
                        }
                    }

                    HStack {
                        Button(connection.state == .suspended || connection.state == .disconnected ? "Réactiver" : "Suspendre") {
                            environment.toggleConnection(id: connection.id)
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        if connection.state != .disconnected {
                            Button("Révoquer", role: .destructive) {
                                connectionToRevoke = connection
                            }
                            .font(.subheadline.weight(.semibold))
                        }
                    }
                }
                .padding(17)
                .glassCard(cornerRadius: 23)
            }
        }
        .confirmationDialog(
            "Révoquer cette connexion ?",
            isPresented: Binding(
                get: { connectionToRevoke != nil },
                set: { if !$0 { connectionToRevoke = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Révoquer", role: .destructive) {
                if let connectionToRevoke {
                    environment.revokeConnection(id: connectionToRevoke.id)
                }
                connectionToRevoke = nil
            }
            Button("Annuler", role: .cancel) { connectionToRevoke = nil }
        } message: {
            Text("FAIT. cessera d’accéder au service. Cette action est simulée dans la version de test.")
        }
    }
}

struct AutonomyPanel: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        VStack(spacing: 14) {
            ForEach(environment.autonomyRules) { rule in
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(rule.title)
                                .font(.headline)
                            Text("Niveau \(rule.level.rawValue) · \(rule.level.title)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(FAITColor.trustGreen)
                        }
                        Spacer()
                        Toggle(
                            "",
                            isOn: Binding(
                                get: { rule.enabled },
                                set: { _ in environment.toggleAutonomy(id: rule.id) }
                            )
                        )
                        .labelsHidden()
                    }

                    Text(rule.detail)
                        .font(.subheadline)
                        .foregroundStyle(FAITColor.mutedText)

                    if rule.alwaysRequiresConfirmation {
                        Label("Confirmation toujours obligatoire", systemImage: "hand.raised.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.orange)
                    }
                }
                .padding(17)
                .glassCard(cornerRadius: 22)
            }
        }
    }
}

struct ProfileInfoCard: View {
    let title: String
    let rows: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 10)
            ForEach(rows, id: \.self) { row in
                HStack {
                    Text(row)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 11)
                if row != rows.last { Divider() }
            }
        }
        .padding(17)
        .glassCard(cornerRadius: 22)
    }
}

struct SignalActionSheet: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    let signalID: UUID

    @State private var acknowledged = false
    @State private var syncToDevice = true
    @State private var recipient = ""
    @State private var subject = ""
    @State private var draftBody = ""

    private var signal: ConnectedSignal? {
        environment.signal(id: signalID)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let signal {
                    VStack(alignment: .leading, spacing: 20) {
                        SignalSheetHeader(signal: signal)

                        SourceCard(signal: signal)

                        switch signal.kind {
                        case .appointment:
                            appointmentContent(signal)
                        case .contract:
                            contractContent(signal)
                        case .vacation:
                            vacationContent(signal)
                        case .invoice:
                            invoiceContent(signal)
                        case .administrative:
                            administrativeContent(signal)
                        }
                    }
                    .padding(20)
                } else {
                    ContentUnavailableView("Élément introuvable", systemImage: "exclamationmark.triangle")
                }
            }
            .background(FAITColor.warmWhite)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
            .task {
                guard let signal, recipient.isEmpty else { return }
                recipient = signal.metadata["replyTo"] ?? signal.sender
                subject = "Re: \(signal.title)"
                draftBody = "Bonjour,\n\nJe vous contacte au sujet de \(signal.title.lowercased()). Pourriez-vous m’indiquer les solutions disponibles ou maintenir les conditions actuelles ?\n\nMerci par avance pour votre retour.\n\nCordialement,\nCyril"
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func appointmentContent(_ signal: ConnectedSignal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailGrid(rows: [
                ("Date", signal.dueDate.map { $0.formatted(date: .long, time: .shortened) } ?? "À vérifier"),
                ("Lieu", signal.metadata["location"] ?? "Non précisé"),
                ("Rappel", "24 heures avant")
            ])

            Toggle("Synchroniser aussi avec le calendrier iPhone", isOn: $syncToDevice)
                .tint(FAITColor.trustGreen)
                .padding(16)
                .glassCard(cornerRadius: 19)

            ConsentToggle(
                isOn: $acknowledged,
                text: "J’ai vérifié la date, l’heure et le lieu du rendez-vous."
            )

            Button {
                _ = environment.createCase(from: signal.id)
                _ = environment.addAgendaEvent(from: signal.id, syncToDevice: syncToDevice)
                dismiss()
            } label: {
                Label("Ajouter et confirmer", systemImage: "calendar.badge.plus")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(!acknowledged)
            .opacity(acknowledged ? 1 : 0.48)
        }
    }

    @ViewBuilder
    private func contractContent(_ signal: ConnectedSignal) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Brouillon préparé")
                .font(.title3.bold())

            TextField("Destinataire", text: $recipient)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            TextField("Objet", text: $subject)
                .textFieldStyle(.roundedBorder)
            TextEditor(text: $draftBody)
                .frame(minHeight: 190)
                .padding(10)
                .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(FAITColor.lightTaupe.opacity(0.45)))

            Label("Le brouillon sera créé, mais aucun message ne sera envoyé.", systemImage: "shield.checkered")
                .font(.caption)
                .foregroundStyle(FAITColor.trustGreen)

            ConsentToggle(
                isOn: $acknowledged,
                text: "J’ai vérifié le destinataire, l’objet et le contenu du brouillon."
            )

            Button {
                _ = environment.createCase(from: signal.id)
                _ = environment.createDraft(
                    for: signal.id,
                    recipient: recipient,
                    subject: subject,
                    body: draftBody
                )
                dismiss()
            } label: {
                Label("Créer le brouillon Gmail", systemImage: "square.and.pencil")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(!acknowledged || recipient.isEmpty || subject.isEmpty || draftBody.isEmpty)
            .opacity(acknowledged ? 1 : 0.48)
        }
    }

    @ViewBuilder
    private func vacationContent(_ signal: ConnectedSignal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailGrid(rows: [
                ("Enfant", signal.metadata["person"] ?? "À vérifier"),
                ("Période", signal.metadata["period"] ?? "À vérifier"),
                ("Formule", signal.metadata["formula"] ?? "À vérifier"),
                ("Coût estimé", signal.amount.map { "\($0) €" } ?? "Non renseigné")
            ])

            Label("La réservation réelle n’est pas exécutée dans cette version. FAIT. prépare uniquement le dossier et la dernière validation restera obligatoire.", systemImage: "hand.raised.fill")
                .font(.subheadline)
                .foregroundStyle(Color.orange)
                .padding(15)
                .background(FAITColor.needsUserBackground.opacity(0.60), in: RoundedRectangle(cornerRadius: 18))

            ConsentToggle(
                isOn: $acknowledged,
                text: "J’ai vérifié l’enfant, les dates, la formule et le coût estimé."
            )

            Button {
                environment.confirmVacation(signalID: signal.id)
                dismiss()
            } label: {
                Label("Confirmer la préparation", systemImage: "checkmark.circle")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(!acknowledged)
            .opacity(acknowledged ? 1 : 0.48)
        }
    }

    @ViewBuilder
    private func invoiceContent(_ signal: ConnectedSignal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailGrid(rows: [
                ("Montant", signal.amount.map { "\($0) €" } ?? "À vérifier"),
                ("Date prévue", signal.dueDate.map { $0.formatted(date: .long, time: .omitted) } ?? "À vérifier"),
                ("Référence", signal.metadata["reference"] ?? "Non détectée"),
                ("Classement proposé", "Logement · Énergie")
            ])

            Button {
                _ = environment.createCase(from: signal.id)
                dismiss()
            } label: {
                Label("Classer dans un dossier", systemImage: "folder.badge.plus")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
    }

    @ViewBuilder
    private func administrativeContent(_ signal: ConnectedSignal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailGrid(rows: [
                ("Organisme", signal.metadata["organization"] ?? signal.sender),
                ("Personne", signal.metadata["person"] ?? "Foyer"),
                ("Échéance", signal.dueDate.map { $0.formatted(date: .long, time: .omitted) } ?? "À vérifier"),
                ("Confiance", "\(Int(signal.confidence * 100)) %")
            ])

            Button {
                _ = environment.createCase(from: signal.id)
                dismiss()
            } label: {
                Label("Créer le dossier", systemImage: "folder.badge.plus")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
    }
}

struct SignalSheetHeader: View {
    let signal: ConnectedSignal

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Image(systemName: signal.kind.systemImage)
                    .font(.title2)
                    .foregroundStyle(FAITColor.trustGreen)
                    .frame(width: 56, height: 56)
                    .background(FAITColor.softSage.opacity(0.24), in: Circle())
                Spacer()
                SignalStateBadge(state: signal.state)
            }
            Text(signal.title)
                .font(.largeTitle.bold())
                .foregroundStyle(FAITColor.oliveCharcoal)
            Text(signal.summary)
                .foregroundStyle(FAITColor.mutedText)
                .lineSpacing(4)
        }
    }
}

struct SourceCard: View {
    let signal: ConnectedSignal

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "link")
                .foregroundStyle(FAITColor.trustGreen)
            VStack(alignment: .leading, spacing: 3) {
                Text("Source")
                    .font(.caption.bold())
                    .foregroundStyle(FAITColor.trustGreen)
                Text(signal.source)
                    .font(.subheadline.weight(.semibold))
                Text("Reçu \(signal.receivedAt.formatted(.relative(presentation: .named))) · \(Int(signal.confidence * 100)) % de confiance")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(15)
        .background(FAITColor.softSage.opacity(0.16), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct DetailGrid: View {
    let rows: [(String, String)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(alignment: .top) {
                    Text(row.0)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(row.1)
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(FAITColor.oliveCharcoal)
                }
                .padding(.vertical, 13)
                if index < rows.count - 1 { Divider() }
            }
        }
        .padding(.horizontal, 16)
        .glassCard(cornerRadius: 20)
    }
}

struct ConsentToggle: View {
    @Binding var isOn: Bool
    let text: String

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(isOn ? FAITColor.trustGreen : FAITColor.mutedText)
                Text(text)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(FAITColor.oliveCharcoal)
                Spacer()
            }
            .padding(15)
            .background(.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}

struct CaseDetailSheet: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    let caseID: UUID

    private var item: FAITCase? { environment.caseItem(id: caseID) }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let item {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.organization.uppercased())
                                    .font(.caption2.bold())
                                    .tracking(1)
                                    .foregroundStyle(FAITColor.trustGreen)
                                Text(item.title)
                                    .font(.largeTitle.bold())
                            }
                            Spacer()
                            StatusBadge(status: item.status)
                        }

                        Text(item.summary)
                            .foregroundStyle(FAITColor.mutedText)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prochaine action")
                                .font(.caption.bold())
                                .foregroundStyle(FAITColor.trustGreen)
                            Text(item.nextAction)
                                .font(.title3.bold())
                            if let dueDate = item.dueDate {
                                Label(dueDate.formatted(date: .long, time: .omitted), systemImage: "calendar")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(17)
                        .glassCard(cornerRadius: 22)

                        if !item.steps.isEmpty {
                            Text("Parcours")
                                .font(.title3.bold())
                            ForEach(item.steps) { step in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: step.state == .completed ? "checkmark.circle.fill" : step.state == .current ? "circle.inset.filled" : "circle")
                                        .foregroundStyle(step.state == .upcoming ? FAITColor.mutedText : FAITColor.trustGreen)
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(step.title)
                                                .font(.headline)
                                            Spacer()
                                            Text(step.owner)
                                                .font(.caption2.bold())
                                                .foregroundStyle(FAITColor.trustGreen)
                                        }
                                        Text(step.detail)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(14)
                                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 18))
                            }
                        }

                        if let proofTitle = item.proofTitle {
                            Label(proofTitle, systemImage: "checkmark.seal.fill")
                                .font(.headline)
                                .foregroundStyle(FAITColor.trustGreen)
                                .padding(17)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(FAITColor.doneBackground, in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(20)
                }
            }
            .background(FAITColor.warmWhite)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct PageTitle: View {
    let eyebrow: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text(eyebrow.uppercased())
                .font(.caption2.bold())
                .tracking(1.2)
                .foregroundStyle(FAITColor.trustGreen)
            Text(title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(FAITColor.oliveCharcoal)
            Text(detail)
                .font(.body)
                .foregroundStyle(FAITColor.mutedText)
                .lineSpacing(3)
        }
        .padding(.top, 4)
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(FAITColor.trustGreen)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(FAITColor.oliveCharcoal)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15)
        .frame(minHeight: 48)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.8)))
        .shadow(color: FAITColor.deepGreen.opacity(0.12), radius: 18, y: 8)
    }
}
