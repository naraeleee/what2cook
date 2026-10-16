import Foundation
import SwiftData

/// One grocery item sitting on a fridge shelf. Nutrition values are per serving.
@Model
final class FridgeItem {
    var name: String
    var category: FoodCategory
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    /// Number of servings left.
    var quantity: Int
    /// Free text such as "140 g" or "1 cup".
    var servingSize: String
    var expirationDate: Date
    var addedAt: Date

    init(
        name: String,
        category: FoodCategory,
        nutrition: Nutrition,
        quantity: Int = 1,
        servingSize: String = "",
        expirationDate: Date,
        addedAt: Date = Date()
    ) {
        self.name = name
        self.category = category
        self.calories = nutrition.calories
        self.protein = nutrition.protein
        self.carbs = nutrition.carbs
        self.fat = nutrition.fat
        self.quantity = quantity
        self.servingSize = servingSize
        self.expirationDate = expirationDate
        self.addedAt = addedAt
    }

    var nutrition: Nutrition {
        Nutrition(calories: calories, protein: protein, carbs: carbs, fat: fat)
    }

    var daysLeft: Int { Expiry.daysUntil(expirationDate) }

    /// Two-letter monogram for the tile, e.g. "Chicken breast" -> "CB", "Quinoa" -> "QU".
    var initials: String {
        let words = name.split(separator: " ").filter { !$0.isEmpty }
        if words.count >= 2, let first = words[0].first, let second = words[1].first {
            return String([first, second]).uppercased()
        }
        return String(name.trimmed.prefix(2)).uppercased()
    }
}
