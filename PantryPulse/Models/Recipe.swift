import Foundation

enum RecipeTone: String {
    case terracotta
    case sage
    case sand
    case slate
}

/// An ingredient the recipe needs, matched against fridge item names by keyword.
struct RecipeIngredient: Hashable {
    let name: String
    let keywords: [String]

    init(_ name: String, keywords: [String]? = nil) {
        self.name = name
        self.keywords = (keywords ?? [name]).map { $0.lowercased() }
    }
}

struct Recipe: Identifiable, Hashable {
    let id: String
    let title: String
    /// Two letters shown on the recipe card artwork.
    let monogram: String
    let minutes: Int
    let tone: RecipeTone
    /// Per serving.
    let nutrition: Nutrition
    let ingredients: [RecipeIngredient]
}

extension Recipe {
    /// Built-in starter catalog. The engine only suggests recipes whose ingredients are all in the fridge.
    static let catalog: [Recipe] = [
        Recipe(
            id: "salmon-asparagus-bowl",
            title: "Pan-Seared Salmon & Asparagus Bowl",
            monogram: "SA",
            minutes: 18,
            tone: .terracotta,
            nutrition: Nutrition(calories: 520, protein: 42, carbs: 18, fat: 28),
            ingredients: [
                RecipeIngredient("Salmon"),
                RecipeIngredient("Asparagus"),
                RecipeIngredient("Baby kale", keywords: ["kale"])
            ]
        ),
        Recipe(
            id: "herby-chicken-quinoa",
            title: "Herby Chicken Quinoa Crunch",
            monogram: "CQ",
            minutes: 16,
            tone: .sage,
            nutrition: Nutrition(calories: 485, protein: 46, carbs: 42, fat: 12),
            ingredients: [
                RecipeIngredient("Chicken breast", keywords: ["chicken"]),
                RecipeIngredient("Quinoa"),
                RecipeIngredient("Baby kale", keywords: ["kale"])
            ]
        ),
        Recipe(
            id: "yogurt-greens-toast",
            title: "Savory Yogurt & Greens Toast",
            monogram: "YG",
            minutes: 10,
            tone: .sand,
            nutrition: Nutrition(calories: 390, protein: 29, carbs: 36, fat: 14),
            ingredients: [
                RecipeIngredient("Greek yogurt", keywords: ["yogurt"]),
                RecipeIngredient("Baby kale", keywords: ["kale"]),
                RecipeIngredient("Asparagus")
            ]
        ),
        Recipe(
            id: "garlic-chicken-asparagus",
            title: "Garlic Chicken & Asparagus Skillet",
            monogram: "GC",
            minutes: 22,
            tone: .slate,
            nutrition: Nutrition(calories: 410, protein: 45, carbs: 12, fat: 19),
            ingredients: [
                RecipeIngredient("Chicken breast", keywords: ["chicken"]),
                RecipeIngredient("Asparagus")
            ]
        ),
        Recipe(
            id: "tahini-kale-quinoa-bowl",
            title: "Tahini Kale & Quinoa Power Bowl",
            monogram: "TK",
            minutes: 12,
            tone: .sage,
            nutrition: Nutrition(calories: 430, protein: 18, carbs: 48, fat: 20),
            ingredients: [
                RecipeIngredient("Quinoa"),
                RecipeIngredient("Baby kale", keywords: ["kale"]),
                RecipeIngredient("Tahini pesto", keywords: ["tahini"])
            ]
        ),
        Recipe(
            id: "overnight-oats",
            title: "Almond Milk Overnight Oats",
            monogram: "OA",
            minutes: 5,
            tone: .sand,
            nutrition: Nutrition(calories: 360, protein: 24, carbs: 46, fat: 9),
            ingredients: [
                RecipeIngredient("Steel-cut oats", keywords: ["oats"]),
                RecipeIngredient("Greek yogurt", keywords: ["yogurt"]),
                RecipeIngredient("Almond milk")
            ]
        ),
        Recipe(
            id: "salmon-quinoa-plate",
            title: "Lemon Salmon & Quinoa Plate",
            monogram: "SQ",
            minutes: 25,
            tone: .terracotta,
            nutrition: Nutrition(calories: 560, protein: 44, carbs: 38, fat: 24),
            ingredients: [
                RecipeIngredient("Salmon"),
                RecipeIngredient("Quinoa")
            ]
        )
    ]
}
