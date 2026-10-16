import SwiftUI
import SwiftData

/// Meal Planner tab: what's left in today's budget, and recipes you can make from the fridge.
struct MealPlannerView: View {
    @Environment(UserSettings.self) private var settings
    @Environment(\.modelContext) private var context
    @Query(sort: \FridgeItem.expirationDate) private var items: [FridgeItem]
    @Query(sort: \LogEntry.date) private var entries: [LogEntry]
    @State private var filters = PlannerFilter.defaults

    private var totals: DayTotals { DayTotals(entries: entries) }

    /// Today's target minus what's eaten and what's already planned.
    private var remaining: Nutrition {
        settings.target - totals.eaten - totals.planned
    }

    private var suggestions: [RecipeSuggestion] {
        RecipeEngine.suggestions(
            inventory: items.map { InventorySnapshot(name: $0.name, daysLeft: $0.daysLeft) },
            remaining: remaining,
            filters: filters
        )
    }

    private var plannedTitles: Set<String> {
        Set(
            entries
                .filter { $0.isPlanned && Calendar.current.isDateInToday($0.date) }
                .map(\.name)
        )
    }

    private var budgetUsed: Double {
        guard settings.calorieTarget > 0 else { return 0 }
        let spent = totals.eaten.calories + totals.planned.calories
        return Double(spent) / Double(settings.calorieTarget)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                    .padding(.horizontal, 20)

                remainingCard
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Overline("Optimize for", color: Theme.inkMuted)
                        .padding(.horizontal, 20)
                    filterChips
                }

                matchesHeader
                    .padding(.horizontal, 20)

                if suggestions.isEmpty {
                    noMatches
                        .padding(.horizontal, 20)
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, suggestion in
                            RecipeCard(
                                suggestion: suggestion,
                                isBestMatch: index == 0,
                                isPlanned: plannedTitles.contains(suggestion.recipe.title),
                                onAdd: { addToPlan(suggestion.recipe) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    // MARK: Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Overline("Smart meal planning", color: Theme.inkMuted)
                Text("What should I eat?")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundStyle(Theme.ink)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            Spacer()
            Button {
                withAnimation(.snappy) { filters = PlannerFilter.defaults }
            } label: {
                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundStyle(Theme.sageInk)
                    .frame(width: 48, height: 48)
                    .background(Theme.sageSoft, in: Circle())
            }
            .accessibilityLabel("Reset suggestions")
        }
    }

    private var remainingCard: some View {
        let balance = settings.projectedBalance

        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Overline("Remaining today", color: Color.white.opacity(0.7))
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(max(remaining.calories, 0).formatted())
                            .font(.system(size: 46, weight: .bold))
                            .foregroundStyle(.white)
                        Text("kcal")
                            .font(.headline)
                            .foregroundStyle(Color.white.opacity(0.7))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Protein left")
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.7))
                    Text("\(max(remaining.protein, 0))g")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                }
            }

            LinearBar(progress: budgetUsed, tint: Theme.tan, track: Color.white.opacity(0.14), height: 7)

            HStack {
                Label(balance <= 0 ? "Projected daily deficit" : "Projected daily surplus", systemImage: "flame")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.75))
                Spacer()
                Text("\(balance <= 0 ? "−" : "+")\(abs(balance).formatted()) kcal")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.tan)
            }
        }
        .padding(22)
        .background(Theme.hero, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.14), radius: 18, x: 0, y: 10)
        .accessibilityElement(children: .combine)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PlannerFilter.allCases) { filter in
                    chip(for: filter)
                }
            }
            .padding(.vertical, 2)
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
    }

    private func chip(for filter: PlannerFilter) -> some View {
        let selected = filters.contains(filter)
        return Button {
            withAnimation(.snappy) {
                if selected {
                    filters.remove(filter)
                } else {
                    filters.insert(filter)
                }
            }
        } label: {
            HStack(spacing: 6) {
                if selected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                }
                Text(filter.title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(selected ? Theme.sage : Theme.sageInk)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(selected ? Theme.sageSoft : Theme.card, in: Capsule())
            .overlay(
                Capsule().stroke(selected ? Theme.sage.opacity(0.35) : Theme.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var matchesHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Best matches")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Theme.ink)
                Text("Made from what you already have")
                    .font(.subheadline)
                    .foregroundStyle(Theme.inkMuted)
            }
            Spacer()
            Text("\(suggestions.count) \(suggestions.count == 1 ? "recipe" : "recipes")")
                .font(.subheadline)
                .foregroundStyle(Theme.inkMuted)
        }
    }

    private var noMatches: some View {
        VStack(spacing: 10) {
            Image(systemName: "fork.knife")
                .font(.system(size: 30))
                .foregroundStyle(Theme.sageInk)
            Text("No recipes match yet")
                .font(.title3)
                .foregroundStyle(Theme.ink)
            Text("Add more groceries to your fridge or turn off a filter.")
                .font(.subheadline)
                .foregroundStyle(Theme.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .cardStyle()
    }

    // MARK: Actions

    private func addToPlan(_ recipe: Recipe) {
        context.insert(
            LogEntry(
                name: recipe.title,
                meal: .suggested(),
                nutrition: recipe.nutrition,
                isPlanned: true
            )
        )
    }
}
