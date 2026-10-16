import Foundation

/// A bundle of calories and macros. Used for targets, servings, recipes and totals.
struct Nutrition: Codable, Hashable {
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int

    static let zero = Nutrition(calories: 0, protein: 0, carbs: 0, fat: 0)

    static func + (lhs: Nutrition, rhs: Nutrition) -> Nutrition {
        Nutrition(
            calories: lhs.calories + rhs.calories,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat
        )
    }

    static func - (lhs: Nutrition, rhs: Nutrition) -> Nutrition {
        Nutrition(
            calories: lhs.calories - rhs.calories,
            protein: lhs.protein - rhs.protein,
            carbs: lhs.carbs - rhs.carbs,
            fat: lhs.fat - rhs.fat
        )
    }
}
