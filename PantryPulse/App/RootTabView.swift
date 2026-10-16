import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            FridgeView()
                .tabItem { Label("Fridge", systemImage: "refrigerator") }

            LogView()
                .tabItem { Label("Log", systemImage: "list.bullet.clipboard") }

            MealPlannerView()
                .tabItem { Label("Meal Planner", systemImage: "fork.knife") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .tint(Theme.sage)
        .toolbarBackground(Theme.card, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            SampleData.seedIfNeeded(in: modelContext)
        }
    }
}
