//
//  Created by Alex.M on 06.07.2022.
//

import Foundation
import SwiftUI

struct MediaPickerThemeKey: EnvironmentKey {
    static var defaultValue: MediaPickerTheme = MediaPickerTheme()
}

extension EnvironmentValues {
    var mediaPickerTheme: MediaPickerTheme {
        get { self[MediaPickerThemeKey.self] }
        set { self[MediaPickerThemeKey.self] = newValue }
    }
}

public extension View {
    func mediaPickerTheme(_ theme: MediaPickerTheme) -> some View {
        self.environment(\.mediaPickerTheme, theme)
    }
}
