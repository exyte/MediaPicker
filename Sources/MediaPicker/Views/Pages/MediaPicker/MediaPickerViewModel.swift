//
// Created by Alex.M on 07.06.2022.
//

import Foundation
import SwiftUI

@MainActor
final class MediaPickerViewModel: ObservableObject {
    
#if os(iOS)
    @Published var showingCamera = false
    @Published var showingCameraSelection = false
    @Published var showingExitCameraConfirmation = false
    @Published var pickedMediaUrl: URL?
#endif

    private let watcher = PhotoLibraryChangePermissionWatcher()
    
    // MARK: Calculated property

    func openCamera() {
        self.showingCamera = true
    }
}
