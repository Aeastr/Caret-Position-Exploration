//
//  cursorPositionApp.swift
//  cursorPosition
//
//  Created by Aether on 29/12/2024.
//

import SwiftUI
import AppKit

@main
struct cursorPositionApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var permissionsService = PermissionsService()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        
        WindowGroup {
            Group{
                if self.permissionsService.isTrusted {
                    ContentView()
                } else {
                    Text("perm issues")
                }
            }
            .onAppear{
                self.permissionsService.pollAccessibilityPrivileges {
                    print("Accessibility permissions granted!")
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

