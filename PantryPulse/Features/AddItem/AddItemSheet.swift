import SwiftUI
import SwiftData

/// "Add to Fridge" sheet: scan (coming soon) or enter an item manually.
struct AddItemSheet: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case scan = "Scan"
        case manual = "Manual Entry"

        var id: String { rawValue }
        var symbol: String { self == .scan ? "viewfinder" : "list.bullet.rectangle" }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var mode: Mode = .manual
    @State private var name = ""
    @State private var category: FoodCategory = .protein
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var quantity = 1
    @State private var servingSize = ""
    @State private var expiration = Date.daysFromToday(7)
    @State private var autoFillNote: String?

    private struct QuickSelect: Identifiable {
        let title: String
        let days: Int
        var id: Int { days }
    }

    private let quickSelects = [
        QuickSelect(title: "+3 days", days: 3),
        QuickSelect(title: "+1 week", days: 7),
        QuickSelect(title: "+2 weeks", days: 14)
    ]

    private var canSave: Bool { !name.trimmed.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    modePicker

                    if mode == .manual {
                        itemDetailsCard
                        nutritionCard
                        freshnessCard
                    } else {
                        scanPlaceholder
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if mode == .manual {
                Button {
                    save()
                } label: {
                    Label("Add to Fridge Shelf", systemImage: "plus")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.background.opacity(0.96))
            }
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
    }

    // MARK: Header & mode switch

    private var header: some View {
        ZStack {
            Text("Add to Fridge")
                .font(.title3)
                .foregroundStyle(Theme.ink)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.sageInk)
                        .frame(width: 40, height: 40)
                        .background(Theme.sageSoft, in: Circle())
                }
                .accessibilityLabel("Close")

                Spacer()

                Button("Cancel") { dismiss() }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.sageInk)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 4)
    }

    private var modePicker: some View {
        HStack(spacing: 4) {
            ForEach(Mode.allCases) { option in
                Button {
                    withAnimation(.snappy) { mode = option }
                } label: {
                    Label(option.rawValue, systemImage: option.symbol)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(mode == option ? Theme.ink : Theme.inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if mode == option {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Theme.hairline.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: Cards

    private var itemDetailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Item details").font(.headline)
                Spacer()
                Text("REQUIRED")
                    .font(.caption.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Theme.amberInk)
            }

            fieldLabel("Item name")
            TextField("e.g. Wild Atlantic salmon", text: $name)
                .textInputAutocapitalization(.sentences)
                .fieldStyle()

            fieldLabel("Category")
            Menu {
                Picker("Category", selection: $category) {
                    ForEach(FoodCategory.allCases) { option in
                        Text(option.pickerLabel).tag(option)
                    }
                }
            } label: {
                HStack {
                    Text(category.pickerLabel)
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                }
                .fieldStyle()
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var nutritionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Nutrition per serving").font(.headline)
                Spacer()
                Button {
                    autoFill()
                } label: {
                    Label("Auto-fill", systemImage: "sparkles")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.sageInk)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.sageSoft, in: Capsule())
                }
            }

            Grid(horizontalSpacing: 14, verticalSpacing: 14) {
                GridRow {
                    numberField("Calories", text: $calories, unit: "kcal")
                    numberField("Protein", text: $protein, unit: "g")
                }
                GridRow {
                    numberField("Carbs", text: $carbs, unit: "g")
                    numberField("Fat", text: $fat, unit: "g")
                }
            }

            if let autoFillNote {
                Text(autoFillNote)
                    .font(.footnote)
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var freshnessCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quantity & freshness").font(.headline)

            Grid(horizontalSpacing: 14, verticalSpacing: 14) {
                GridRow(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("Quantity")
                        HStack {
                            Text("\(quantity) \(quantity == 1 ? "serving" : "servings")")
                                .font(.body.weight(.medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer(minLength: 4)
                            Stepper("Quantity", value: $quantity, in: 1...99)
                                .labelsHidden()
                        }
                        .fieldStyle()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("Serving size")
                        TextField("e.g. 140 g", text: $servingSize)
                            .font(.body.weight(.medium))
                            .fieldStyle()
                    }
                }
            }

            fieldLabel("Expiration date")
            DatePicker("Date", selection: $expiration, displayedComponents: .date)
                .fieldStyle()

            HStack(spacing: 8) {
                Text("Quick select")
                    .font(.caption)
                    .foregroundStyle(Theme.inkMuted)
                ForEach(quickSelects) { option in
                    Button(option.title) {
                        expiration = Date.daysFromToday(option.days)
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.sageInk)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Theme.sageSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var scanPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "viewfinder")
                .font(.system(size: 40))
                .foregroundStyle(Theme.sageInk)
            Text("Scan a receipt or barcode")
                .font(.title3)
                .foregroundStyle(Theme.ink)
            Text("Camera scanning is coming soon. For now, add items with Manual Entry.")
                .font(.subheadline)
                .foregroundStyle(Theme.inkMuted)
                .multilineTextAlignment(.center)
            Button("Use Manual Entry") {
                withAnimation(.snappy) { mode = .manual }
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Theme.sageInk)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Theme.sageSoft, in: Capsule())
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    // MARK: Small pieces

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.inkMuted)
    }

    private func numberField(_ title: String, text: Binding<String>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)
            HStack(spacing: 6) {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .font(.body.weight(.medium))
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(Theme.inkMuted)
            }
            .fieldStyle()
        }
    }

    // MARK: Actions

    private func autoFill() {
        guard !name.trimmed.isEmpty else {
            autoFillNote = "Enter an item name first."
            return
        }
        if let match = FoodDatabase.lookup(name) {
            calories = String(match.nutrition.calories)
            protein = String(match.nutrition.protein)
            carbs = String(match.nutrition.carbs)
            fat = String(match.nutrition.fat)
            if servingSize.trimmed.isEmpty {
                servingSize = match.servingSize
            }
            autoFillNote = "Filled in from “\(match.name)”. Adjust anything that looks off."
        } else {
            autoFillNote = "No match found. Enter the values manually."
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
        context.insert(
            FridgeItem(
                name: name.trimmed,
                category: category,
                nutrition: nutrition,
                quantity: quantity,
                servingSize: servingSize.trimmed,
                expirationDate: expiration
            )
        )
        dismiss()
    }
}
