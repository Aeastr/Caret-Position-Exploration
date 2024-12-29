//
//  cursorPositionApp.swift
//  cursorPosition
//
//  Created by Aether on 29/12/2024.
//

import SwiftUI

@main
struct cursorPositionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
