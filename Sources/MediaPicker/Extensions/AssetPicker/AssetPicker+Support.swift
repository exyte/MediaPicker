//
//  Created by Alex.M on 07.06.2022.
//

import Foundation
import SwiftUI

extension View {
    func mediaPickerToolbar(mode: Binding<MediaPickerMode>) -> some View {
        Picker("", selection: mode) {
            ForEach(MediaPickerMode.allCases) { mode in
                Text(mode.name)
                    .tag(mode)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: UIScreen.main.bounds.width / 2)
    }
}
