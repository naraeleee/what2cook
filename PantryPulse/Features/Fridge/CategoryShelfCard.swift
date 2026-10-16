import SwiftUI

/// One "shelf" of the fridge: a card for a food category, soonest-to-expire items first.
struct CategoryShelfCard: View {
    let category: FoodCategory
    /// Already sorted by expiration date.
    let items: [FridgeItem]

    var body: some View {
        NavigationLink {
            CategoryDetailView(category: category)
        } label: {
            VStack(spacing: 12) {
                HStack {
                    Text(category.shelfTitle)
                        .font(.title3)
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
                .padding(.horizontal, 4)

                ForEach(items) { item in
                    FridgeItemRow(item: item)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}
