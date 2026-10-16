import SwiftUI

// MARK: - Card & field styling

struct CardStyle: ViewModifier {
    var radius: CGFloat = 26

    func body(content: Content) -> some View {
        content
            .background(Theme.card, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 5)
    }
}

struct FieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .frame(minHeight: 54)
            .background(Theme.inset, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(radius: CGFloat = 26) -> some View {
        modifier(CardStyle(radius: radius))
    }

    func fieldStyle() -> some View {
        modifier(FieldStyle())
    }
}

// MARK: - Text

/// Small, tracked, uppercase label that sits above a title ("YOUR INVENTORY").
struct Overline: View {
    let text: String
    var color: Color

    init(_ text: String, color: Color = Theme.sageInk) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.bold))
            .tracking(1.4)
            .foregroundStyle(color)
    }
}

/// Rounded status pill ("14 items", "Expires in 2 days").
struct Pill: View {
    let text: String
    let fill: Color
    let ink: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .multilineTextAlignment(.center)
            .foregroundStyle(ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(fill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// Amber / green / red pill that reflects how soon an item expires.
struct ExpiryPill: View {
    let daysLeft: Int

    var body: some View {
        Pill(text: Expiry.pillText(daysLeft: daysLeft), fill: fill, ink: ink)
            .fixedSize()
    }

    private var fill: Color {
        switch Expiry.tone(daysLeft: daysLeft) {
        case .expired: return Theme.redFill
        case .soon: return Theme.amberFill
        case .fresh: return Theme.sageSoft
        }
    }

    private var ink: Color {
        switch Expiry.tone(daysLeft: daysLeft) {
        case .expired: return Theme.redInk
        case .soon: return Theme.amberInk
        case .fresh: return Theme.sageInk
        }
    }
}

// MARK: - Progress

struct ProgressRing: View {
    /// 0...1 (values above 1 are drawn as a full ring, the label still shows the real percentage).
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.14), lineWidth: 6)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(Theme.tan, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int((progress * 100).rounded()))%")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(width: 66, height: 66)
    }
}

struct LinearBar: View {
    let progress: Double
    let tint: Color
    var track: Color = Color.white.opacity(0.14)
    var height: CGFloat = 5

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(track)
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: height)
    }
}

// MARK: - Tiles & buttons

/// Rounded tile with two letters, standing in for a food photo.
struct ItemBadge: View {
    let text: String
    let fill: Color
    var size: CGFloat = 48

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.3, weight: .bold))
            .foregroundStyle(Theme.badgeInk)
            .frame(width: size, height: size)
            .background(fill, in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    /// A tonal button is used for "already done" states, such as a recipe already on the day plan.
    var tonal = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(tonal ? Theme.sage : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                tonal ? Theme.sageSoft : Theme.sage,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .shadow(color: tonal ? Color.clear : Theme.sage.opacity(0.28), radius: 12, x: 0, y: 6)
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

/// Round dark-green button that floats over a screen.
struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Theme.sage, in: Circle())
                .overlay(Circle().stroke(Theme.card, lineWidth: 3))
                .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 8)
        }
        .accessibilityLabel("Add groceries")
    }
}

/// Icon tile + overline + title + message, centered. Used for empty tabs.
struct EmptyStateView: View {
    let symbol: String
    let overline: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(Theme.sageInk)
                .frame(width: 100, height: 100)
                .background(Theme.sageSoft, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.bottom, 8)

            Overline(overline, color: Theme.inkMuted)

            Text(title)
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(Theme.inkMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            if let actionTitle, let action {
                Button(action: action) {
                    Label(actionTitle, systemImage: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 17)
                        .background(Theme.sage, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Theme.sage.opacity(0.28), radius: 12, x: 0, y: 6)
                }
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
