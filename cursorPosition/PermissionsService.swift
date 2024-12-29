import Cocoa

final class PermissionsService: ObservableObject {
    /// Store the active trust state of the app.
    @Published var isTrusted: Bool = AXIsProcessTrusted()
    
    /// Poll the accessibility state every 2 seconds and update the trust status.
    /// Optionally executes a completion handler when permissions are acquired.
    func pollAccessibilityPrivileges(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isTrusted = AXIsProcessTrusted()
            print("[PermissionsService] - Trust status: \(self.isTrusted)")
            if self.isTrusted {
                completion?()
            } else {
                self.pollAccessibilityPrivileges(completion: completion)
            }
        }
    }
    
    /// Request accessibility permissions by prompting the macOS dialog.
    /// Opens System Preferences to the correct page if not already trusted.
    static func acquireAccessibilityPrivileges() {
        print("[PermissionsService] - Requesting accessibility permissions")
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        _ = AXIsProcessTrustedWithOptions(options)
    }
}
