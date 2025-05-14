//
//  SwipebookApp.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import SwiftUI
import SwiftData

@main
struct SwipebookApp: App {
    init() {
        // Force the app to always use dark mode
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        // Large Navigation Title
        UINavigationBar
            .appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        // Inline Navigation Title
        UINavigationBar
            .appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
