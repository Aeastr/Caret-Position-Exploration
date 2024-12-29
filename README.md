
# **Caret Position Exploration - Testing Grounds**

This repository is a **testing application** developed to explore and experiment with macOS Accessibility APIs for retrieving the text cursor's position and bounding rectangle in various macOS applications. 

This is **NOT a packaged library or framework** but rather a test app used to understand how the underlying Accessibility API functions. If you're looking for a polished Swift package, please refer to the appropriate package repositories.

---

## **What This Is**
- A playground for experimenting with Accessibility API calls.
- Includes a basic macOS app that queries the focused application's text caret position and bounds.
- Logs detailed debug information to help understand how the API behaves.

---

## **What This Is NOT**
- A production-ready tool or package.
- A reusable library.

---

## **Usage**
To explore or modify the test app:

1. Clone this repository:
   ```bash
   git clone https://github.com/Aeastr/Caret-Position-Exploration.git
   ```

2. Open the project in Xcode:
   ```bash
   open cursorPosition.xcodeproj
   ```

3. Ensure **Accessibility permissions** are granted:
   - Go to **System Preferences > Privacy & Security > Accessibility**.
   - Add the app to the list and ensure it is checked.

4. Run the app in Xcode and observe logs to understand how caret position retrieval behaves.

---

## **Requirements**
- **macOS 12.0+**
- **Swift 5.5+**
- Accessibility permissions must be granted.

---

## **Why This Exists**
This repository serves as a foundational experiment for working with macOS Accessibility APIs. The code here is not meant for deployment but as a learning tool and reference for future Accessibility projects.

---

## **License**
This project is licensed under the [MIT License](LICENSE).

---

## **Acknowledgments**
- Inspired by the need to better understand text cursor behavior in macOS.
- Built to debug and experiment with macOS's Accessibility features.
