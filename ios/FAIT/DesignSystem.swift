import SwiftUI

enum FAITColor {
    static let trustGreen = Color(hex: 0x2E6B4F)
    static let softSage = Color(hex: 0xA8C5B0)
    static let warmWhite = Color(hex: 0xFAF7F2)
    static let lightTaupe = Color(hex: 0xCFC6B8)
    static let oliveCharcoal = Color(hex: 0x2B2E28)

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

struct TrustSeal: View {
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(FAITColor.softSage.opacity(0.55))
            Circle()
                .fill(FAITColor.trustGreen)
                .padding(size * 0.14)
            Image(systemName: "checkmark")
                .font(.system(size: size * 0.34, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct StatusBadge: View {
    let status: CaseStatus

    private var background: Color {
        switch status {
        case .toDo: FAITColor.toDoBackground
        case .inProgress: FAITColor.inProgressBackground
        case .needsUser: FAITColor.needsUserBackground
        case .done: FAITColor.doneBackground
        }
    }

    private var foreground: Color {
        switch status {
        case .toDo: Color(hex: 0x76591F)
        case .inProgress: Color(hex: 0x285C80)
        case .needsUser: Color(hex: 0x8A4E24)
        case .done: FAITColor.trustGreen
        }
    }

    var body: some View {
        Label(status.rawValue, systemImage: status.systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(background, in: Capsule())
            .accessibilityElement(children: .combine)
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .padding(.horizontal, 16)
            .background(
                FAITColor.trustGreen.opacity(configuration.isPressed ? 0.82 : 1),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(FAITColor.trustGreen)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.horizontal, 16)
            .background(
                FAITColor.warmWhite,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(FAITColor.trustGreen.opacity(0.5), lineWidth: 1)
            }
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

struct CaseCardView: View {
    let item: FAITCase

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.title3)
                    .foregroundStyle(FAITColor.trustGreen)
                    .frame(width: 42, height: 42)
                    .background(FAITColor.softSage.opacity(0.28), in: Circle())

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
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(FAITColor.lightTaupe.opacity(0.35), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.035), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
    }
}

struct SectionTitle: View {
    let title: String
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(FAITColor.oliveCharcoal)
            Spacer()
            if let action {
                Button("Voir tout", action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}
