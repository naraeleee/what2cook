import SwiftUI

/// "Today's progress" card: calorie ring plus protein, carbs and fat bars.
struct MacroSummaryCard: View {
    let eaten: Nutrition
    let target: Nutrition

    private var progress: Double {
        target.calories > 0 ? Double(eaten.calories) / Double(target.calories) : 0
    }

    private var headline: String {
        switch progress {
        case ..<0.01: return "Ready when you are"
        case ..<0.25: return "Just getting started"
        case ..<0.9: return "Right on track"
        case ...1.05: return "Right at target"
        default: return "Over target"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Overline("Today’s progress", color: Color.white.opacity(0.7))
                    Text(headline)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                ProgressRing(progress: progress)
            }

            Divider().overlay(Color.white.opacity(0.15))

            Grid(horizontalSpacing: 28, verticalSpacing: 18) {
                GridRow {
                    macro("Calories", value: eaten.calories, target: target.calories, unit: "", tint: Theme.tan)
                    macro("Protein", value: eaten.protein, target: target.protein, unit: "g", tint: Theme.sageLight)
                }
                GridRow {
                    macro("Carbs", value: eaten.carbs, target: target.carbs, unit: "g", tint: Color(hex: 0xDDBF8E))
                    macro("Fat", value: eaten.fat, target: target.fat, unit: "g", tint: Theme.lavender)
                }
            }
        }
        .padding(22)
        .background(Theme.hero, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.14), radius: 18, x: 0, y: 10)
        .accessibilityElement(children: .combine)
    }

    private func macro(_ label: String, value: Int, target: Int, unit: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.75))
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(value.formatted())\(unit)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text("/ \(target.formatted())\(unit)")
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            LinearBar(progress: target > 0 ? Double(value) / Double(target) : 0, tint: tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
