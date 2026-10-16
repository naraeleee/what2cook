import SwiftUI
import SwiftData

/// Full list for one shelf. Swipe right to eat a serving, swipe left to remove the item.
struct CategoryDetailView: View {
    let category: FoodCategory

    @Environment(\.modelContext) private var context
    @Query(sort: \FridgeItem.expirationDate) private var allItems: [FridgeItem]

    private var items: [FridgeItem] {
        allItems.filter { $0.category == category }
    }

    var body: some View {
        List {
            ForEach(items) { item in
                FridgeItemRow(item: item, showsQuantity: true)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .leading) {
                        Button {
                            eatOneServing(of: item)
                        } label: {
                            Label("Eat 1", systemImage: "fork.knife")
                        }
                        .tint(Theme.sage)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            context.delete(item)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(category.shelfTitle)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if items.isEmpty {
                ContentUnavailableView(
                    "Shelf is empty",
                    systemImage: "refrigerator",
                    description: Text("Add groceries from the Fridge tab.")
                )
            }
        }
    }

    /// Logs one serving as eaten and uses it up from the fridge.
    private func eatOneServing(of item: FridgeItem) {
        context.insert(
            LogEntry(name: item.name, meal: .suggested(), nutrition: item.nutrition)
        )
        item.quantity -= 1
        if item.quantity <= 0 {
            context.delete(item)
        }
    }
}
