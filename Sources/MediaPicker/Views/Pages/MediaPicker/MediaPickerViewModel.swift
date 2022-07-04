//
// Created by Alex.M on 07.06.2022.
//

import Foundation
import SwiftUI

@MainActor
final class MediaPickerViewModel: ObservableObject {
    @Published var mode: MediaPickerMode = .photos
#if os(iOS)
    @Published var showCamera = false
    @Published var cameraImage: URL?
#endif

    private let watcher = PhotoLibraryChangePermissionWatcher()
    
    // MARK: Calculated property

    func openCamera() {
        self.showCamera = true
    }
}
