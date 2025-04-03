//
// Created by Alex.M on 07.06.2022.
//

import Foundation
import SwiftUI

@MainActor
final class MediaPickerViewModel: ObservableObject {

#if os(iOS)
    @Published var showingExitCameraConfirmation = false
    @Published var pickedMediaUrl: URL?
#endif

    @Published private(set) var defaultAlbumsProvider = DefaultAlbumsProvider()
    @Published private(set) var internalPickerMode: MediaPickerMode = .photos

    var albums: [AlbumModel] {
        defaultAlbumsProvider.albums
    }

    var shouldUpdatePickerMode: (MediaPickerMode)->() = {_ in}

    func onStart() {
        defaultAlbumsProvider.reload()
    }

    func getAlbumModel(_ album: Album) -> AlbumModel? {
        albums.filter { $0.id == album.id }.first
    }

    func setPickerMode(_ mode: MediaPickerMode) {
        internalPickerMode = mode
        shouldUpdatePickerMode(mode)
    }

    func onCancelCameraSelection(_ hasSelected: Bool) {
        if hasSelected {
            showingExitCameraConfirmation = true
        } else {
            setPickerMode(.camera)
        }
    }
}
