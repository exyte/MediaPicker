//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Photos
import SwiftUI

final class AlbumMediasProvider: BaseMediasProvider {

    let album: AlbumModel

    init(album: AlbumModel, selectionParamsHolder: SelectionParamsHolder, filterClosure: MediaPicker.FilterClosure? = nil, massFilterClosure: MediaPicker.MassFilterClosure? = nil) {
        self.album = album
        super.init(selectionParamsHolder: selectionParamsHolder, filterClosure: filterClosure, massFilterClosure: massFilterClosure)
    }

    override func reload() {
        PermissionsService.shared.requestPhotoLibraryPermission { [weak self] in
            DispatchQueue.main.async {
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

        let assets = MediasProvider.map(fetchResult: fetchResult, mediaSelectionType: selectionParamsHolder.mediaType)
        filterAndPublish(assets: assets)
    }
}
