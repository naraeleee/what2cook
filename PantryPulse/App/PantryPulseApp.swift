import SwiftUI
import SwiftData

@main
struct PantryPulseApp: App {
    @State private var settings = UserSettings()

    private let container: ModelContainer = {
        do {
            return try ModelContainer(for: FridgeItem.self, LogEntry.self)
        } catch {
            fatalError("Could not create the SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(settings)
                // The design is light-only for now.
                .preferredColorScheme(.light)
        }
        .modelContainer(container)
    }
}
