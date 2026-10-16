import SwiftUI
import SwiftData

/// Home tab: macro progress on top, then the fridge as a stack of category shelves.
struct FridgeView: View {
    @Environment(UserSettings.self) private var settings
    @Query(sort: \FridgeItem.expirationDate) private var items: [FridgeItem]
    @Query(sort: \LogEntry.date) private var entries: [LogEntry]
    @State private var showingAdd = false

    private struct Shelf: Identifiable {
        let category: FoodCategory
        let items: [FridgeItem]
        var id: String { category.id }
    }

    private var shelves: [Shelf] {
        FoodCategory.allCases.compactMap { category in
            let inCategory = items.filter { $0.category == category }
            return inCategory.isEmpty ? nil : Shelf(category: category, items: inCategory)
        }
    }

    private var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let part = hour < 12 ? "morning" : (hour < 17 ? "afternoon" : "evening")
        return "Good \(part), \(settings.name)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    MacroSummaryCard(
                        eaten: DayTotals(entries: entries).eaten,
                        target: settings.target
                    )

                    inventoryHeader

                    if shelves.isEmpty {
                        emptyFridge
                    } else {
                        ForEach(shelves) { shelf in
                            CategoryShelfCard(category: shelf.category, items: shelf.items)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .background(Theme.background.ignoresSafeArea())
            .overlay(alignment: .bottomTrailing) {
                FloatingAddButton { showingAdd = true }
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAdd) {
                AddItemSheet()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Overline(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                Text(greeting)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundStyle(Theme.ink)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            Spacer()
            Text(String(settings.name.prefix(1)).uppercased())
                .font(.headline)
                .foregroundStyle(Theme.badgeInk)
                .frame(width: 46, height: 46)
                .background(Color(hex: 0xB5C4B3), in: Circle())
                .overlay(Circle().stroke(Theme.hairline, lineWidth: 1))
                .accessibilityHidden(true)
        }
    }

    private var inventoryHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Overline("Your inventory", color: Theme.inkMuted)
                Text("Smart Fridge")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Theme.ink)
            }
            Spacer()
            Pill(
                text: "\(itemCount) \(itemCount == 1 ? "item" : "items")",
                fill: Theme.sageSoft,
                ink: Theme.sageInk
            )
        }
    }

    private var emptyFridge: some View {
        VStack(spacing: 10) {
            Image(systemName: "refrigerator")
                .font(.system(size: 32))
                .foregroundStyle(Theme.sageInk)
            Text("Your fridge is empty")
                .font(.title3)
                .foregroundStyle(Theme.ink)
            Text("Tap + to add your first grocery item.")
                .font(.subheadline)
                .foregroundStyle(Theme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .cardStyle()
    }
}
