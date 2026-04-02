//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Photos
import SwiftUI

final class AlbumMediasProvider: BaseMediasProvider {

    let album: AlbumModel

    init(album: AlbumModel, mediaPickerParams: MediaPickerCutomizationParameters) {
        self.album = album
        super.init(mediaPickerParams: mediaPickerParams)
    }

    override func reload() {
        PermissionsService.shared.requestPhotoLibraryPermission {
            DispatchQueue.main.async { [weak self] in
                self?.reloadInternal()
            }
        }
    }

    func reloadInternal() {
        isLoading = true
        defer {
            isLoading = false
        }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let fetchResult = PHAsset.fetchAssets(in: album.source, options: fetchOptions)
        if fetchResult.count == 0 {
            assetMediaModels = []
        }

        let assets = MediasProvider.map(fetchResult: fetchResult, mediaSelectionType: mediaPickerParams.selectionParameters.mediaType)
        filterAndPublish(assets: assets)
    }
}
