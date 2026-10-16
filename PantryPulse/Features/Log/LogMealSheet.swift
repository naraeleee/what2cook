import SwiftUI
import SwiftData

/// Quick form to log a meal or snack you ate.
struct LogMealSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var meal = MealSlot.suggested()
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    private var canSave: Bool { !name.trimmed.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("What did you eat?") {
                    TextField("Meal or snack", text: $name)
                    Picker("Meal", selection: $meal) {
                        ForEach(MealSlot.allCases) { slot in
                            Text(slot.title).tag(slot)
                        }
                    }
                }

                Section("Nutrition") {
                    numberRow("Calories", text: $calories, unit: "kcal")
                    numberRow("Protein", text: $protein, unit: "g")
                    numberRow("Carbs", text: $carbs, unit: "g")
                    numberRow("Fat", text: $fat, unit: "g")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Log a meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.large])
        .presentationBackground(Theme.background)
    }

    private func numberRow(_ title: String, text: Binding<String>, unit: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 90)
            Text(unit)
                .foregroundStyle(Theme.inkMuted)
                .frame(width: 34, alignment: .leading)
        }
    }

    private func save() {
        guard canSave else { return }
        let nutrition = Nutrition(
            calories: Int(calories) ?? 0,
            protein: Int(protein) ?? 0,
            carbs: Int(carbs) ?? 0,
            fat: Int(fat) ?? 0
        )
        context.insert(LogEntry(name: name.trimmed, meal: meal, nutrition: nutrition))
        dismiss()
    }
}
