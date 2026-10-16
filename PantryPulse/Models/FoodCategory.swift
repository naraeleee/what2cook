import Foundation

enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case protein
    case carb
    case produce
    case fat
    case beverage
    case condiment

    var id: String { rawValue }

    /// Heading shown on the fridge shelf card.
    var shelfTitle: String {
        switch self {
        case .protein: return "Proteins"
        case .carb: return "Complex Carbs"
        case .produce: return "Produce & Greens"
        case .fat: return "Healthy Fats"
        case .beverage: return "Beverages"
        case .condiment: return "Sauces & Condiments"
        }
    }

    /// Label shown in the category dropdown of the Add to Fridge form.
    var pickerLabel: String {
        switch self {
        case .protein: return "Protein"
        case .carb: return "Carb"
        case .produce: return "Produce"
        case .fat: return "Fat"
        case .beverage: return "Beverage"
        case .condiment: return "Condiment"
        }
    }
}
