//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

public enum MediaSelectionStyle {
    case checkmark
    case count
}

struct MediaSelectionStyleKey: EnvironmentKey {
    static var defaultValue: MediaSelectionStyle = .checkmark
}

extension EnvironmentValues {
    var mediaSelectionStyle: MediaSelectionStyle {
        get { self[MediaSelectionStyleKey.self] }
        set { self[MediaSelectionStyleKey.self] = newValue }
    }
}

public extension View {
    func selectionStyle(_ style: MediaSelectionStyle) -> some View {
        self.environment(\.mediaSelectionStyle, style)
    }
}
