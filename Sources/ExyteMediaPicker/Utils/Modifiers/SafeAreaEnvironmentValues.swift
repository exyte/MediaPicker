//
//  SafeAreaEnvironmentValues.swift
//
//
//  Created by Alexandra Afonasova on 18.10.2022.
//

import SwiftUI

struct MediaPickerSafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = EdgeInsets()
}

struct MediaPickerContentWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var mediaPickerSafeAreaInsets: EdgeInsets {
        get { self[MediaPickerSafeAreaInsetsKey.self] }
        set { self[MediaPickerSafeAreaInsetsKey.self] = newValue }
    }

    /// Width available inside the safe area, measured once at the `MediaPicker` root.
    var mediaPickerContentWidth: CGFloat {
        get { self[MediaPickerContentWidthKey.self] }
        set { self[MediaPickerContentWidthKey.self] = newValue }
    }
}
