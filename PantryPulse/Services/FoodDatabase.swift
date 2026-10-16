import Foundation

struct FoodReference {
    /// Lowercase key matched against what the person typed.
    let name: String
    let nutrition: Nutrition
    let servingSize: String
}

/// A tiny built-in lookup that powers the "Auto-fill" chip. A real nutrition API can replace this later.
enum FoodDatabase {
    static let entries: [FoodReference] = [
        FoodReference(name: "salmon", nutrition: Nutrition(calories: 220, protein: 30, carbs: 0, fat: 12), servingSize: "140 g"),
        FoodReference(name: "chicken breast", nutrition: Nutrition(calories: 165, protein: 31, carbs: 0, fat: 4), servingSize: "100 g"),
        FoodReference(name: "greek yogurt", nutrition: Nutrition(calories: 100, protein: 17, carbs: 6, fat: 0), servingSize: "170 g"),
        FoodReference(name: "quinoa", nutrition: Nutrition(calories: 220, protein: 8, carbs: 39, fat: 4), servingSize: "1 cup"),
        FoodReference(name: "oats", nutrition: Nutrition(calories: 150, protein: 5, carbs: 27, fat: 3), servingSize: "40 g"),
        FoodReference(name: "asparagus", nutrition: Nutrition(calories: 27, protein: 3, carbs: 5, fat: 0), servingSize: "134 g"),
        FoodReference(name: "kale", nutrition: Nutrition(calories: 35, protein: 2, carbs: 4, fat: 1), servingSize: "60 g"),
        FoodReference(name: "almond milk", nutrition: Nutrition(calories: 30, protein: 1, carbs: 1, fat: 3), servingSize: "1 cup"),
        FoodReference(name: "egg", nutrition: Nutrition(calories: 70, protein: 6, carbs: 0, fat: 5), servingSize: "1 large egg"),
        FoodReference(name: "tofu", nutrition: Nutrition(calories: 94, protein: 10, carbs: 2, fat: 6), servingSize: "100 g"),
        FoodReference(name: "avocado", nutrition: Nutrition(calories: 240, protein: 3, carbs: 13, fat: 22), servingSize: "1 whole"),
        FoodReference(name: "broccoli", nutrition: Nutrition(calories: 55, protein: 4, carbs: 11, fat: 1), servingSize: "1 cup"),
        FoodReference(name: "brown rice", nutrition: Nutrition(calories: 215, protein: 5, carbs: 45, fat: 2), servingSize: "1 cup"),
        FoodReference(name: "black beans", nutrition: Nutrition(calories: 220, protein: 15, carbs: 40, fat: 1), servingSize: "1 cup"),
        FoodReference(name: "cottage cheese", nutrition: Nutrition(calories: 90, protein: 12, carbs: 5, fat: 2), servingSize: "113 g"),
        FoodReference(name: "olive oil", nutrition: Nutrition(calories: 119, protein: 0, carbs: 0, fat: 14), servingSize: "1 tbsp")
    ]

    /// Best (longest) match for what the person typed, or nil if nothing fits.
    static func lookup(_ query: String) -> FoodReference? {
        let q = query.trimmed.lowercased()
        guard !q.isEmpty else { return nil }
        return entries
            .filter { q.contains($0.name) || (q.count >= 3 && $0.name.contains(q)) }
            .max { $0.name.count < $1.name.count }
    }
}
