//
//  AppDelegate.swift
//  cursorPosition
//
//  Created by Aether on 29/12/2024.
//


//
//  AppDelegate.swift
//  auto-clicker
//
//  Created by Ben on 30/03/2022.
//

import Foundation
import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    // When the application finishes launching, request the
    //  accessibility permissions from the service class we
    //  made earlier.
    func applicationDidFinishLaunching(_ notification: Notification) {
        PermissionsService.acquireAccessibilityPrivileges()
    }
}