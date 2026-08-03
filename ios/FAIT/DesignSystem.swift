import SwiftUI

enum FAITColor {
    static let trustGreen = Color(hex: 0x2E6B4F)
    static let deepGreen = Color(hex: 0x183F2F)
    static let softSage = Color(hex: 0xA8C5B0)
    static let warmWhite = Color(hex: 0xFAF7F2)
    static let cream = Color(hex: 0xF5F1E9)
    static let lightTaupe = Color(hex: 0xCFC6B8)
    static let oliveCharcoal = Color(hex: 0x2B2E28)
    static let mutedText = Color(hex: 0x6E746D)

    static let toDoBackground = Color(hex: 0xF3E8CF)
    static let inProgressBackground = Color(hex: 0xDCEAF7)
    static let needsUserBackground = Color(hex: 0xF9E0CF)
    static let doneBackground = Color(hex: 0xDDEDE3)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct SealShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.03))
        path.addCurve(
            to: CGPoint(x: w * 0.80, y: h * 0.13),
            control1: CGPoint(x: w * 0.61, y: h * 0.03),
            control2: CGPoint(x: w * 0.70, y: h * 0.12)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.97, y: h * 0.42),
            control1: CGPoint(x: w * 0.90, y: h * 0.16),
            control2: CGPoint(x: w * 0.92, y: h * 0.31)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.90, y: h * 0.76),
            control1: CGPoint(x: w * 1.00, y: h * 0.54),
            control2: CGPoint(x: w * 0.92, y: h * 0.65)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.60, y: h * 0.97),
            control1: CGPoint(x: w * 0.84, y: h * 0.88),
            control2: CGPoint(x: w * 0.70, y: h * 0.91)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.27, y: h * 0.91),
            control1: CGPoint(x: w * 0.48, y: h * 1.00),
            control2: CGPoint(x: w * 0.38, y: h * 0.93)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.04, y: h * 0.65),
            control1: CGPoint(x: w * 0.14, y: h * 0.88),
            control2: CGPoint(x: w * 0.09, y: h * 0.77)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.09, y: h * 0.31),
            control1: CGPoint(x: w * 0.00, y: h * 0.53),
            control2: CGPoint(x: w * 0.05, y: h * 0.40)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.36, y: h * 0.06),
            control1: CGPoint(x: w * 0.14, y: h * 0.18),
            control2: CGPoint(x: w * 0.25, y: h * 0.10)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.03),
            control1: CGPoint(x: w * 0.41, y: h * 0.04),
            control2: CGPoint(x: w * 0.46, y: h * 0.03)
        )
        path.closeSubpath()
        return path
    }
}

struct TrustSeal: View {
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            SealShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x5C9071), FAITColor.trustGreen, FAITColor.deepGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: FAITColor.deepGreen.opacity(0.18), radius: size * 0.12, y: size * 0.08)

            Circle()
                .fill(.white.opacity(0.12))
                .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 1))
                .padding(size * 0.20)

            Image(systemName: "checkmark")
                .font(.system(size: size * 0.31, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct BrandLockup: View {
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 9 : 12) {
            TrustSeal(size: compact ? 38 : 48)
            VStack(alignment: .leading, spacing: 1) {
                Text("FAIT.")
                    .font(compact ? .headline.bold() : .title2.bold())
                    .foregroundStyle(FAITColor.deepGreen)
                Text(compact ? "Votre quotidien, allégé." : "Vous demandez. C’est fait.")
                    .font(compact ? .caption2 : .caption)
                    .foregroundStyle(FAITColor.mutedText)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct StatusBadge: View {
    let status: CaseStatus

    private var colors: (Color, Color) {
        switch status {
        case .toDo: (FAITColor.toDoBackground, Color(hex: 0x76591F))
        case .inProgress: (FAITColor.inProgressBackground, Color(hex: 0x285C80))
        case .needsUser: (FAITColor.needsUserBackground, Color(hex: 0x8A4E24))
        case .done: (FAITColor.doneBackground, FAITColor.trustGreen)
        }
    }

    var body: some View {
        Label(status.rawValue, systemImage: status.systemImage)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(colors.1)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(colors.0, in: Capsule())
    }
}

struct SignalStateBadge: View {
    let state: SignalState

    private var colors: (Color, Color) {
        switch state {
        case .detected: (FAITColor.softSage.opacity(0.24), FAITColor.deepGreen)
        case .prepared: (FAITColor.inProgressBackground, Color(hex: 0x285C80))
        case .needsConfirmation: (FAITColor.needsUserBackground, Color(hex: 0x8A4E24))
        case .synchronized: (FAITColor.doneBackground, FAITColor.trustGreen)
        case .done: (FAITColor.doneBackground, FAITColor.deepGreen)
        }
    }

    var body: some View {
        Text(state.rawValue)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(colors.1)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(colors.0, in: Capsule())
    }
}

struct ConnectionStateBadge: View {
    let state: ConnectionState

    var body: some View {
        Text(state.rawValue)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(state == .disconnected ? FAITColor.mutedText : FAITColor.deepGreen)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(
                state == .disconnected ? Color.gray.opacity(0.10) : FAITColor.softSage.opacity(0.28),
                in: Capsule()
            )
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .padding(.horizontal, 16)
            .background(
                FAITColor.trustGreen.opacity(configuration.isPressed ? 0.82 : 1),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(color: FAITColor.deepGreen.opacity(0.14), radius: 14, y: 7)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(FAITColor.trustGreen)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .padding(.horizontal, 16)
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(FAITColor.trustGreen.opacity(0.28), lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.88), lineWidth: 1)
            }
            .shadow(color: FAITColor.deepGreen.opacity(0.07), radius: 22, y: 10)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

struct CaseCardView: View {
    let item: FAITCase

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "folder.fill")
                    .font(.title3)
                    .foregroundStyle(FAITColor.trustGreen)
                    .frame(width: 44, height: 44)
                    .background(FAITColor.softSage.opacity(0.24), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(FAITColor.oliveCharcoal)
                    Text(item.organization)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)
                StatusBadge(status: item.status)
            }

            Text(item.nextAction)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FAITColor.oliveCharcoal)

            HStack {
                Label(item.person, systemImage: "person")
                Spacer()
                Text(item.updatedAt, format: .relative(presentation: .named))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(17)
        .glassCard(cornerRadius: 22)
        .accessibilityElement(children: .combine)
    }
}

struct SectionTitle: View {
    let eyebrow: String?
    let title: String
    var actionTitle: String = "Voir tout"
    var action: (() -> Void)?

    init(eyebrow: String? = nil, title: String, actionTitle: String = "Voir tout", action: (() -> Void)? = nil) {
        self.eyebrow = eyebrow
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 5) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(.caption2.bold())
                        .tracking(1.2)
                        .foregroundStyle(FAITColor.trustGreen)
                }
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(FAITColor.oliveCharcoal)
            }
            Spacer()
            if let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}
