import SwiftUI
import AppKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var inputText: String = ""
    @State private var logs: [String] = [] // Logs for debugging
    @State private var timer: Timer? // Timer for periodic updates
    @StateObject private var permissionsService = PermissionsService() // Permission check service
    
    var body: some View {
        VStack {
            headerSection
            
            if permissionsService.isTrusted {
                mainContent
            } else {
                permissionsIssueView
            }
        }
        .padding()
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Cursor Position Checker")
                .font(.headline)
                .padding(.bottom, 5)
            
            Button("Check Permissions Again") {
                permissionsService.pollAccessibilityPrivileges()
            }
            .padding()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 20) {
            inputSection
            caretActionsSection
            logsSection
        }
        .onAppear {
            permissionsService.pollAccessibilityPrivileges()
        }
        .onDisappear {
            stopCheckingFocus() // Stop timer when the view disappears
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Enter text", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack {
                Button("Start Checking") {
                    startCheckingFocus()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Stop Checking") {
                    stopCheckingFocus()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal)
        }
    }

    private var caretActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                checkCaretRect()
            } label: {
                Text("Get Caret Rect")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
        }
    }

    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Logs:")
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(logs, id: \.self) { log in
                        Text(log)
                            .font(.caption)
                            .padding(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .border(Color.gray, width: 0.2)
                    }
                }
            }
            .frame(maxHeight: 300) // Limit scrollable area height
            .padding()
            .border(Color.blue, width: 1)
        }
    }

    private var permissionsIssueView: some View {
        VStack(spacing: 10) {
            Text("Accessibility permissions are required to run this app.")
                .multilineTextAlignment(.center)
                .padding()
            Button("Check Permissions Again") {
                permissionsService.pollAccessibilityPrivileges()
            }
            .padding()
        }
    }

    // MARK: - Helper Functions

    private func checkCaretRect() {
        if let focusedElement = frontmostFocusedElement() {
            if let caretRect = focusedElement.getInsertionPointRect() {
                appendLog("Caret rect: \(caretRect)")
            } else {
                appendLog("No caret rect found or unsupported app.")
            }
        } else {
            appendLog("No focused element or unsupported app.")
        }
    }

    private func startCheckingFocus() {
        stopCheckingFocus() // Ensure any previous timer is invalidated
        appendLog("Started checking focus.")
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            checkCaretRect()
        }
    }

    private func stopCheckingFocus() {
        timer?.invalidate()
        timer = nil
        appendLog("Stopped checking focus.")
    }

    private func appendLog(_ message: String) {
        logs.append("[\(Date().formatted(date: .omitted, time: .standard))] \(message)")
        print("[\(Date().formatted(date: .omitted, time: .standard))] \(message)")
        if logs.count > 50 {
            logs.removeFirst(logs.count - 50) // Keep only the latest 50 logs
        }
    }
}

// MARK: - Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(5)
    }
}
