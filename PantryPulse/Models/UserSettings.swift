import Foundation
import Observation

/// Daily targets and display name. In-memory for now; the Profile tab will edit and persist these.
@Observable
final class UserSettings {
    var name = "Alex"
    var calorieTarget = 1830
    var proteinTarget = 140
    var carbTarget = 190
    var fatTarget = 61
    /// Estimated maintenance calories, used for the projected daily deficit.
    var maintenanceCalories = 2280

    var target: Nutrition {
        Nutrition(calories: calorieTarget, protein: proteinTarget, carbs: carbTarget, fat: fatTarget)
    }

    /// Negative = deficit, positive = surplus, assuming the day ends exactly on target.
    var projectedBalance: Int { calorieTarget - maintenanceCalories }
}
