import Foundation

/// A fridge item reduced to what the recipe engine needs, so the engine stays UI- and database-free.
struct InventorySnapshot: Hashable {
    let name: String
    let daysLeft: Int
}

/// Chips on the Meal Planner.
/// - `expiringSoon` and `highProtein` re-weight the ranking.
/// - `quick` and `lowCarb` are hard filters.
enum PlannerFilter: String, CaseIterable, Identifiable {
    case expiringSoon
    case highProtein
    case quick
    case lowCarb

    var id: String { rawValue }

    var title: String {
        switch self {
        case .expiringSoon: return "Use Expiring Soon"
        case .highProtein: return "High Protein"
        case .quick: return "< 20 Min"
        case .lowCarb: return "Low Carb"
        }
    }

    static let defaults: Set<PlannerFilter> = [.expiringSoon, .highProtein]
}

struct RecipeSuggestion: Identifiable, Hashable {
    let recipe: Recipe
    /// Names of fridge items this recipe uses that are expiring soon.
    let expiringItems: [String]
    /// Share of the remaining protein budget this recipe covers (0...1).
    let proteinCoverage: Double
    let proteinRemaining: Int
    /// Calories still unspent after eating this; negative means over budget.
    let caloriesLeft: Int
    let score: Double

    var id: String { recipe.id }
}

enum RecipeEngine {
    static let lowCarbLimit = 25
    static let quickLimitMinutes = 20

    /// Recipes you can make right now from the fridge, best match first.
    static func suggestions(
        from recipes: [Recipe] = Recipe.catalog,
        inventory: [InventorySnapshot],
        remaining: Nutrition,
        filters: Set<PlannerFilter>
    ) -> [RecipeSuggestion] {
        let usable = inventory.filter { $0.daysLeft >= 0 }
        var results: [RecipeSuggestion] = []

        for recipe in recipes {
            if filters.contains(.quick) && recipe.minutes >= quickLimitMinutes { continue }
            if filters.contains(.lowCarb) && recipe.nutrition.carbs > lowCarbLimit { continue }
            guard let matched = match(recipe, in: usable) else { continue }

            let expiringNames = matched
                .filter { $0.daysLeft <= Expiry.soonThreshold }
                .sorted { $0.daysLeft < $1.daysLeft }
                .map(\.name)
            let uniqueExpiring = expiringNames.reduce(into: [String]()) { names, name in
                if !names.contains(name) { names.append(name) }
            }

            let coverage: Double = remaining.protein > 0
                ? min(1, Double(recipe.nutrition.protein) / Double(remaining.protein))
                : 1
            let caloriesLeft = remaining.calories - recipe.nutrition.calories
            let calorieFit: Double = remaining.calories > 0
                ? max(0, 1 - Double(abs(caloriesLeft)) / Double(remaining.calories))
                : 0

            var score = coverage * (filters.contains(.highProtein) ? 3.0 : 1.5)
            score += calorieFit
            score += Double(uniqueExpiring.count) * (filters.contains(.expiringSoon) ? 2.0 : 0.5)
            if caloriesLeft < 0 { score -= 2 }

            results.append(
                RecipeSuggestion(
                    recipe: recipe,
                    expiringItems: uniqueExpiring,
                    proteinCoverage: coverage,
                    proteinRemaining: remaining.protein,
                    caloriesLeft: caloriesLeft,
                    score: score
                )
            )
        }

        return results.sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            return $0.recipe.title < $1.recipe.title
        }
    }

    /// For each ingredient, picks the matching fridge item that expires soonest.
    /// Returns nil if any ingredient is missing.
    private static func match(_ recipe: Recipe, in inventory: [InventorySnapshot]) -> [InventorySnapshot]? {
        var used: [InventorySnapshot] = []
        for ingredient in recipe.ingredients {
            let candidates = inventory.filter { item in
                let name = item.name.lowercased()
                return ingredient.keywords.contains { name.contains($0) }
            }
            guard let best = candidates.min(by: { $0.daysLeft < $1.daysLeft }) else { return nil }
            used.append(best)
        }
        return used
    }
}
