//
//  KeyboardHeightHelper.swift
//  Example-iOS
//
//  Created by Alisa Mylnikova on 23.08.2023.
//

import SwiftUI

#if compiler(>=6.0)
extension Notification: @retroactive @unchecked Sendable { }
#else
extension Notification: @unchecked Sendable { }
#endif

@MainActor
class KeyboardHeightHelper: ObservableObject {

    static let shared = KeyboardHeightHelper()

    @Published var keyboardHeight: CGFloat = 0
    @Published var keyboardDisplayed: Bool = false

    init() {
        self.listenForKeyboardNotifications()
    }

    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }

            Task { @MainActor in
                    // Safely extract the data from the notification on the main actor
                    guard let userInfo = notification.userInfo,
                          let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

                    // Now update the UI on the main actor
                    self.keyboardHeight = keyboardRect.height
                    self.keyboardDisplayed = true
                }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            DispatchQueue.main.async {
                self.keyboardHeight = 0
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { (notification) in
            DispatchQueue.main.async {
                self.keyboardDisplayed = false
            }
        }
    }

    private func handleKeyboardWillShow(_ notification: Notification) {
           guard let userInfo = notification.userInfo,
                 let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
               return
           }
           self.keyboardHeight = keyboardRect.height
           self.keyboardDisplayed = true
       }
}
