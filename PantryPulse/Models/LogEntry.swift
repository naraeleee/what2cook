import Foundation
import SwiftData

enum MealSlot: String, Codable, CaseIterable, Identifiable {
    case breakfast
    case lunch
    case dinner
    case snack

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }

    /// A sensible default slot for the time of day.
    static func suggested(for date: Date = Date(), calendar: Calendar = .current) -> MealSlot {
        switch calendar.component(.hour, from: date) {
        case 4..<11: return .breakfast
        case 11..<15: return .lunch
        case 15..<17: return .snack
        case 17..<22: return .dinner
        default: return .snack
        }
    }
}

/// A meal or snack the person ate (or, with `isPlanned`, intends to eat today).
@Model
final class LogEntry {
    var name: String
    var meal: MealSlot
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var date: Date
    var isPlanned: Bool

    init(
        name: String,
        meal: MealSlot,
        nutrition: Nutrition,
        date: Date = Date(),
        isPlanned: Bool = false
    ) {
        self.name = name
        self.meal = meal
        self.calories = nutrition.calories
        self.protein = nutrition.protein
        self.carbs = nutrition.carbs
        self.fat = nutrition.fat
        self.date = date
        self.isPlanned = isPlanned
    }

    var nutrition: Nutrition {
        Nutrition(calories: calories, protein: protein, carbs: carbs, fat: fat)
    }
}

/// Today's eaten and planned totals, derived from the log.
struct DayTotals {
    let eaten: Nutrition
    let planned: Nutrition

    init(entries: [LogEntry], now: Date = Date(), calendar: Calendar = .current) {
        var eaten = Nutrition.zero
        var planned = Nutrition.zero
        for entry in entries where calendar.isDate(entry.date, inSameDayAs: now) {
            if entry.isPlanned {
                planned = planned + entry.nutrition
            } else {
                eaten = eaten + entry.nutrition
            }
        }
        self.eaten = eaten
        self.planned = planned
    }
}
