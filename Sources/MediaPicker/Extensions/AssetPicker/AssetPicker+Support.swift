//
//  Created by Alex.M on 07.06.2022.
//

import Foundation
import SwiftUI

extension View {
    func cameraSheet(isShow: Binding<Bool>, image: Binding<URL?>) -> some View {

#if targetEnvironment(simulator)
        self.fullScreenCover(isPresented: isShow) {
            CameraStubView(isShow: isShow)
        }
#elseif os(iOS)
        self.fullScreenCover(isPresented: isShow) {
            CameraView(url: image, isShown: isShow)
        }
#endif
    }

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
            }
        }
    }

    func mediaPickerNavigationBar(mode: Binding<MediaPickerMode>, close: @escaping () -> Void) -> some View {
        self
            .mediaPickerToolbar(mode: mode)
            .navigationBarTitleDisplayMode(.inline)
    }
}
