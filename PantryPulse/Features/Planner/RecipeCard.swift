import SwiftUI

/// One suggested recipe: artwork, what it uses from the fridge, macros and its impact on today's budget.
struct RecipeCard: View {
    let suggestion: RecipeSuggestion
    let isBestMatch: Bool
    let isPlanned: Bool
    let onAdd: () -> Void

    private var recipe: Recipe { suggestion.recipe }
    private var percent: Int { Int((suggestion.proteinCoverage * 100).rounded()) }

    private var usesText: String {
        switch suggestion.expiringItems.count {
        case 0: return "Made from your fridge"
        case 1: return "Uses 1 item expiring soon"
        default: return "Uses \(suggestion.expiringItems.count) items expiring soon"
        }
    }

    private var impactTitle: String {
        suggestion.proteinRemaining > 0
            ? "Fulfills \(percent)% of remaining protein"
            : "Protein target already met"
    }

    private var impactDetail: String {
        suggestion.caloriesLeft >= 0
            ? "Leaves \(suggestion.caloriesLeft) kcal remaining"
            : "Over today’s budget by \(-suggestion.caloriesLeft) kcal"
    }

    var body: some View {
        VStack(spacing: 0) {
            artwork
            details
        }
        .cardStyle()
    }

    private var artwork: some View {
        ZStack {
            recipe.tone.gradient

            Circle()
                .stroke(Color.white.opacity(0.16), lineWidth: 34)
                .frame(width: 190, height: 190)
                .offset(x: -150, y: 60)
            Circle()
                .fill(Color.white.opacity(0.13))
                .frame(width: 120, height: 120)
                .offset(x: 140, y: -60)

            Text(recipe.monogram)
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 96, height: 96)
                .background(Color.white.opacity(0.18), in: Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
        }
        .frame(height: 176)
        .overlay(alignment: .topLeading) {
            if isBestMatch {
                Label("BEST MATCH", systemImage: "sparkles")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.35), in: Capsule())
                    .padding(14)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Label("\(recipe.minutes) min", systemImage: "clock")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.35), in: Capsule())
                .padding(14)
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 26,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 26,
                style: .continuous
            )
        )
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "leaf")
                Text(usesText.uppercased())
                    .tracking(1)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(Theme.sageInk)

            Text(recipe.title)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(recipe.nutrition.calories) kcal · \(recipe.nutrition.protein)g Protein · \(recipe.nutrition.carbs)g Carb")
                .font(.subheadline)
                .foregroundStyle(Theme.inkMuted)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(impactTitle)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Text(impactDetail)
                        .font(.caption)
                        .foregroundStyle(Theme.inkMuted)
                }
                Spacer(minLength: 8)
                Text("\(percent)%")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Theme.sageInk)
            }
            .padding(14)
            .background(Theme.insetGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button(action: onAdd) {
                if isPlanned {
                    Label("Added to Day Plan", systemImage: "checkmark")
                } else {
                    Text("Add to Day Plan")
                }
            }
            .buttonStyle(PrimaryButtonStyle(tonal: isPlanned))
            .disabled(isPlanned)
        }
        .padding(18)
    }
}
