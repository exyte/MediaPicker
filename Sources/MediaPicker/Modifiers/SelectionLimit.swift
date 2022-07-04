//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

struct MediaSelectionLimitKey: EnvironmentKey {
    static var defaultValue: Int = 10
}

extension EnvironmentValues {
    var mediaSelectionLimit: Int {
        get { self[MediaSelectionLimitKey.self] }
        set { self[MediaSelectionLimitKey.self] = newValue }
    }
}

public extension View {
    func mediaSelectionLimit(_ value: Int) -> some View {
        self.environment(\.mediaSelectionLimit, value)
    }
}
