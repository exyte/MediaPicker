//
//  Created by Alex.M on 06.07.2022.
//

import Foundation
import SwiftUI

public extension EnvironmentValues {
    @Entry var mediaPickerTheme = MediaPickerTheme()
    @Entry var mediaPickerThemeIsOverridden = false
}

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
