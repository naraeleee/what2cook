import SwiftUI

/// One item on a shelf: initials tile, name, protein/calories and the expiry pill.
struct FridgeItemRow: View {
    let item: FridgeItem
    var showsQuantity = false

    private var detail: String {
        var text = "\(item.protein)g P · \(item.calories) kcal"
        if showsQuantity {
            text += " · ×\(item.quantity)"
        }
        return text
    }

    var body: some View {
        HStack(spacing: 14) {
            ItemBadge(text: item.initials, fill: item.category.badgeFill)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Theme.inkMuted)
            }

            Spacer(minLength: 8)

            ExpiryPill(daysLeft: item.daysLeft)
        }
        .padding(12)
        .background(Theme.inset, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
