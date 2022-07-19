//
//  Created by Alex.M on 07.06.2022.
//

import Foundation
import SwiftUI

extension View {

    func mediaPickerToolbar(mode: Binding<MediaPickerMode>) -> some View {
        self.toolbar {
            ToolbarItem(placement: .principal) {
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
    }

    func mediaPickerNavigationBar(mode: Binding<MediaPickerMode>) -> some View {
        self
            .mediaPickerToolbar(mode: mode)
            .navigationBarTitleDisplayMode(.inline)
    }
}
