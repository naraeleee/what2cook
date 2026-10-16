import SwiftUI

/// Profile tab. Placeholder until targets and preferences are editable.
struct ProfileView: View {
    var body: some View {
        EmptyStateView(
            symbol: "person",
            overline: "Your account",
            title: "Profile & goals",
            message: "Your nutrition targets, preferences, and PantryPulse settings live here."
        )
        .background(Theme.background.ignoresSafeArea())
    }
}
