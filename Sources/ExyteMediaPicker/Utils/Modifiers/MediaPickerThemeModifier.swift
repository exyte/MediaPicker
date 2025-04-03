//
//  Created by Alex.M on 06.07.2022.
//

import Foundation
import SwiftUI

public extension EnvironmentValues {
    #if swift(>=6.0)
    @Entry var mediaPickerTheme = MediaPickerTheme()
    @Entry var mediaPickerThemeIsOverridden = false
    #else
    var mediaPickerTheme: MediaPickerTheme {
        get { self[MediaPickerThemeKey.self] }
        set { self[MediaPickerThemeKey.self] = newValue }
    }

    var mediaPickerThemeIsOverridden: Bool {
        get { self[MediaPickerThemeIsOverriddenKey.self] }
        set { self[MediaPickerThemeIsOverriddenKey.self] = newValue }
    }
    #endif
}

// Define keys only for older versions
#if swift(<6.0)
@preconcurrency public struct MediaPickerThemeKey: EnvironmentKey {
    public static let defaultValue = MediaPickerTheme()
}

public struct MediaPickerThemeIsOverriddenKey: EnvironmentKey {
    public static let defaultValue = false
}
#endif

public extension View {
    func mediaPickerTheme(_ theme: MediaPickerTheme) -> some View {
        self.environment(\.mediaPickerTheme, theme)
            .environment(\.mediaPickerThemeIsOverridden, true)
    }

    func mediaPickerTheme(
        main: MediaPickerTheme.Main = .init(),
        selection: MediaPickerTheme.Selection = .init(),
        cellStyle: MediaPickerTheme.CellStyle = .init(),
        error: MediaPickerTheme.Error = .init(),
        defaultHeader: MediaPickerTheme.DefaultHeader = .init()
    ) -> some View {
        self.environment(\.mediaPickerTheme, MediaPickerTheme(main: main, selection: selection, cellStyle: cellStyle, error: error, defaultHeader: defaultHeader))
            .environment(\.mediaPickerThemeIsOverridden, true)
    }
}
