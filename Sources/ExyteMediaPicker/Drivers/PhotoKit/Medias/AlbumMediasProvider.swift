//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import Photos

final class AlbumMediasProvider: MediasProviderProtocol {
    
    private var subject = CurrentValueSubject<[AssetMediaModel], Never>([])
    private var subscriptions = Set<AnyCancellable>()

    let album: AlbumModel
    let selectionParamsHolder: SelectionParamsHolder

    var assetMediaModels: AnyPublisher<[AssetMediaModel], Never> {
        subject.eraseToAnyPublisher()
    }

    init(album: AlbumModel, selectionParamsHolder: SelectionParamsHolder) {
        self.album = album
        self.selectionParamsHolder = selectionParamsHolder
        photoLibraryChangePermissionPublisher
            .sink { [weak self] in
                self?.reload()
            }
            .store(in: &subscriptions)
    }

    func reload() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let fetchResult = PHAsset.fetchAssets(in: album.source, options: fetchOptions)
        if fetchResult.count == 0 {
            subject.send([])
        }
        let assets = MediasProvider.map(fetchResult: fetchResult, mediaSelectionType: selectionParamsHolder.mediaType)
        DispatchQueue.main.async { [weak self] in
            self?.subject.send(assets)
        }
    }
}
