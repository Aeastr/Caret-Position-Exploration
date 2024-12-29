//
//  curosrpos.swift
//  cursorPosition
//
//  Created

import Cocoa
import AppKit
import ApplicationServices
import Accessibility

func castCF<T, U>(_ value: T, to type: U.Type = U.self) -> U? {
    print("[castCF] - Attempting to cast value of type \(T.self) to \(U.self)")
    return value as? U
}

extension AXUIElement {
    /// Attempts to return the bounding rect of the insertion point (a.k.a. cursor)
    /// in the current text area, if applicable. Prioritizes fallback methods first.
    func getInsertionPointRect() -> CGRect? {
        print("[getInsertionPointRect] - Start")

        // Attempt to use fallback bounds (AXFrame or AXPosition) first
        if let fallbackBounds = getFallbackBounds() {
            print("[getInsertionPointRect] - Successfully obtained fallback bounds: \(fallbackBounds)")
            return fallbackBounds
        }

        print("[getInsertionPointRect] - Fallback bounds not available. Trying AXBoundsForRange.")

        // Obtain the "insertion point" or selection offset
        guard let cursorPosition = getCursorPosition() else {
            print("[getInsertionPointRect] - Failed to get cursor position")
            return nil
        }
        print("[getInsertionPointRect] - Cursor position: \(cursorPosition)")

        // Prepare a CFRange with length 1 for the single caret position
        var cfRange = CFRange(location: cursorPosition, length: 1)
        guard let axValueRange = AXValueCreate(.cfRange, &cfRange) else {
            print("[getInsertionPointRect] - Failed to create AXValue from CFRange")
            return nil
        }

        // Attempt to get the bounding rect
        var rawBounds: CFTypeRef?
        let error = AXUIElementCopyParameterizedAttributeValue(
            self,
            kAXBoundsForRangeParameterizedAttribute as CFString,
            axValueRange,
            &rawBounds
        )
        print("[getInsertionPointRect] - AXUIElementCopyParameterizedAttributeValue result: \(error)")

        guard error == .success,
              let boundsCF = castCF(rawBounds, to: AXValue.self) else {
            print("[getInsertionPointRect] - Failed to get boundsCF or cast it to AXValue")
            return nil
        }

        // Convert CFTypeRef → AXValue → CGRect
        var rect = CGRect.zero
        if AXValueGetValue(boundsCF, .cgRect, &rect) {
            print("[getInsertionPointRect] - Successfully obtained rect: \(rect)")
            return rect
        } else {
            print("[getInsertionPointRect] - Failed to extract CGRect from AXValue")
        }

        return nil
    }

    /// Helper that returns the integer offset of the insertion caret
    private func getCursorPosition() -> Int? {
        print("[getCursorPosition] - Start")

        // Attempt to get the `AXSelectedTextRange` attribute
        let kAXSelectedTextRange = "AXSelectedTextRange"
        var rawValue: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(
            self,
            kAXSelectedTextRange as CFString,
            &rawValue
        )
        print("[getCursorPosition] - AXUIElementCopyAttributeValue result: \(error)")

        guard error == .success,
              let axRangeValue = castCF(rawValue, to: AXValue.self) else {
            print("[getCursorPosition] - Failed to get rawValue or cast it to AXValue")
            return nil
        }

        var range = CFRange()
        if AXValueGetValue(axRangeValue, .cfRange, &range) {
            print("[getCursorPosition] - Successfully obtained range: \(range)")
            return range.location
        } else {
            print("[getCursorPosition] - Failed to extract CFRange from AXValue")
        }

        return nil
    }

    /// Fallback method to retrieve bounds using AXFrame or AXPosition
    private func getFallbackBounds() -> CGRect? {
        print("[getFallbackBounds] - Attempting to fetch alternative bounds")
        let kAXFrameAttribute = "AXFrame"
        let kAXPositionAttribute = "AXPosition"

        // Try to get the frame of the element
        var frameValue: CFTypeRef?
        let frameError = AXUIElementCopyAttributeValue(self, kAXFrameAttribute as CFString, &frameValue)

        if frameError == .success, let axFrame = castCF(frameValue, to: AXValue.self) {
            var frame = CGRect.zero
            if AXValueGetValue(axFrame, .cgRect, &frame) {
                print("[getFallbackBounds] - Successfully obtained frame: \(frame)")
                return frame
            }
        }
        print("[getFallbackBounds] - Failed to fetch AXFrame")

        // Try to get the position of the element
        var positionValue: CFTypeRef?
        let positionError = AXUIElementCopyAttributeValue(self, kAXPositionAttribute as CFString, &positionValue)

        if positionError == .success, let axPosition = castCF(positionValue, to: AXValue.self) {
            var position = CGPoint.zero
            if AXValueGetValue(axPosition, .cgPoint, &position) {
                print("[getFallbackBounds] - Successfully obtained position: \(position)")
                return CGRect(origin: position, size: CGSize(width: 0, height: 0))
            }
        }
        print("[getFallbackBounds] - Failed to fetch AXPosition")

        return nil
    }
}

func frontmostFocusedElement() -> AXUIElement? {
    print("[frontmostFocusedElement] - Start")
    
    // Ensure permissions are granted
    guard AXIsProcessTrusted() else {
        print("[frontmostFocusedElement] - Accessibility permissions not granted")
        return nil
    }
    
    let systemWideElement = AXUIElementCreateSystemWide()
    print("[frontmostFocusedElement] - Created systemWideElement")
    
    var appRef: CFTypeRef?
    let resultApp = AXUIElementCopyAttributeValue(
        systemWideElement,
        kAXFocusedApplicationAttribute as CFString,
        &appRef
    )
    print("[frontmostFocusedElement] - AXUIElementCopyAttributeValue for app result: \(resultApp)")
    
    // Handle all possible AXError cases
    guard resultApp == .success, let app = castCF(appRef, to: AXUIElement.self) else {
        switch resultApp {
        case .actionUnsupported:
            print("[frontmostFocusedElement] - The requested action is unsupported")
        case .apiDisabled:
            print("[frontmostFocusedElement] - Accessibility API is disabled")
        case .attributeUnsupported:
            print("[frontmostFocusedElement] - The requested attribute is unsupported")
        case .cannotComplete:
            print("[frontmostFocusedElement] - The operation cannot be completed")
        case .failure:
            print("[frontmostFocusedElement] - Generic failure occurred")
        case .illegalArgument:
            print("[frontmostFocusedElement] - Illegal argument provided")
        case .invalidUIElement:
            print("[frontmostFocusedElement] - Invalid UI element")
        case .invalidUIElementObserver:
            print("[frontmostFocusedElement] - Invalid UI element observer")
        case .noValue:
            print("[frontmostFocusedElement] - No focused app available")
        case .notEnoughPrecision:
            print("[frontmostFocusedElement] - Not enough precision for the operation")
        case .notImplemented:
            print("[frontmostFocusedElement] - The requested functionality is not implemented")
        case .notificationAlreadyRegistered:
            print("[frontmostFocusedElement] - Notification already registered")
        case .notificationNotRegistered:
            print("[frontmostFocusedElement] - Notification not registered")
        case .notificationUnsupported:
            print("[frontmostFocusedElement] - Notification unsupported")
        case .parameterizedAttributeUnsupported:
            print("[frontmostFocusedElement] - Parameterized attribute unsupported")
        case .success:
            // This case is not possible here since `resultApp != .success` was checked in the guard.
            break
        default:
            print("[frontmostFocusedElement] - Unknown error: \(resultApp)")
        }
        return nil
    }
    
    print("[frontmostFocusedElement] - Successfully retrieved app: \(app)")
    
    var focusedElementRef: CFTypeRef?
    let resultElement = AXUIElementCopyAttributeValue(
        app,
        kAXFocusedUIElementAttribute as CFString,
        &focusedElementRef
    )
    print("[frontmostFocusedElement] - AXUIElementCopyAttributeValue for element result: \(resultElement)")
    
    guard resultElement == .success, let focused = castCF(focusedElementRef, to: AXUIElement.self) else {
        switch resultElement {
        case .actionUnsupported:
            print("[frontmostFocusedElement] - Focused element does not support the requested action")
        case .attributeUnsupported:
            print("[frontmostFocusedElement] - Focused element does not support the requested attribute")
        case .cannotComplete:
            print("[frontmostFocusedElement] - Cannot complete operation on the focused element")
        case .failure:
            print("[frontmostFocusedElement] - Generic failure when retrieving focused element")
        case .invalidUIElement:
            print("[frontmostFocusedElement] - Focused element is invalid")
        case .noValue:
            print("[frontmostFocusedElement] - No focused element available in the app")
        case .parameterizedAttributeUnsupported:
            print("[frontmostFocusedElement] - Parameterized attribute unsupported for focused element")
        case .success:
            // This case is not possible here since `resultElement != .success` was checked in the guard.
            break
        default:
            print("[frontmostFocusedElement] - Unknown error when retrieving focused element: \(resultElement)")
        }
        return nil
    }
    
    print("[frontmostFocusedElement] - Successfully retrieved focused element: \(focused)")
    return focused
}
