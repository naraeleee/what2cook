import Foundation
import SwiftData

/// Seeds the fridge and today's log on first launch so the app matches the design mockups.
/// Delete this file and the `seedIfNeeded` call in `RootTabView` to start with an empty fridge.
enum SampleData {
    private static let seededKey = "pantrypulse.sampleDataSeeded"

    @MainActor
    static func seedIfNeeded(in context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        UserDefaults.standard.set(true, forKey: seededKey)

        let items: [FridgeItem] = [
            FridgeItem(name: "Chicken breast", category: .protein,
                       nutrition: Nutrition(calories: 165, protein: 31, carbs: 0, fat: 4),
                       quantity: 2, servingSize: "100 g", expirationDate: .daysFromToday(2)),
            FridgeItem(name: "Greek yogurt", category: .protein,
                       nutrition: Nutrition(calories: 100, protein: 17, carbs: 6, fat: 0),
                       quantity: 2, servingSize: "170 g", expirationDate: .daysFromToday(5)),
            FridgeItem(name: "Cooked quinoa", category: .carb,
                       nutrition: Nutrition(calories: 220, protein: 8, carbs: 39, fat: 4),
                       quantity: 2, servingSize: "1 cup", expirationDate: .daysFromToday(1)),
            FridgeItem(name: "Steel-cut oats", category: .carb,
                       nutrition: Nutrition(calories: 150, protein: 5, carbs: 27, fat: 3),
                       quantity: 1, servingSize: "40 g", expirationDate: .daysFromToday(18)),
            FridgeItem(name: "Asparagus", category: .produce,
                       nutrition: Nutrition(calories: 27, protein: 3, carbs: 5, fat: 0),
                       quantity: 2, servingSize: "134 g", expirationDate: .daysFromToday(2)),
            FridgeItem(name: "Baby kale", category: .produce,
                       nutrition: Nutrition(calories: 35, protein: 2, carbs: 4, fat: 1),
                       quantity: 1, servingSize: "60 g", expirationDate: .daysFromToday(6)),
            FridgeItem(name: "Almond milk", category: .beverage,
                       nutrition: Nutrition(calories: 30, protein: 1, carbs: 1, fat: 3),
                       quantity: 2, servingSize: "1 cup", expirationDate: .daysFromToday(8)),
            FridgeItem(name: "Tahini pesto", category: .condiment,
                       nutrition: Nutrition(calories: 90, protein: 2, carbs: 3, fat: 8),
                       quantity: 2, servingSize: "2 tbsp", expirationDate: .daysFromToday(12))
        ]
        items.forEach { context.insert($0) }

        // Together these add up to 1,180 kcal · 92g protein · 118g carbs · 42g fat.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        func at(_ hour: Int, _ minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
        }
        let meals: [LogEntry] = [
            LogEntry(name: "Overnight oats & berries", meal: .breakfast,
                     nutrition: Nutrition(calories: 340, protein: 24, carbs: 38, fat: 10), date: at(8, 0)),
            LogEntry(name: "Chicken & quinoa bowl", meal: .lunch,
                     nutrition: Nutrition(calories: 520, protein: 46, carbs: 44, fat: 20), date: at(12, 30)),
            LogEntry(name: "Protein smoothie & banana", meal: .snack,
                     nutrition: Nutrition(calories: 320, protein: 22, carbs: 36, fat: 12), date: at(15, 30))
        ]
        meals.forEach { context.insert($0) }
    }
}
