//
//  Created by Alex.M on 09.06.2022.
//

import Foundation

import Foundation
import Photos
import Combine

final class AllPhotosProvider: MediasProviderProtocol {
    
    private var subject = CurrentValueSubject<[AssetMediaModel], Never>([])
    private var subscriptions = Set<AnyCancellable>()

    var assetMediaModels: AnyPublisher<[AssetMediaModel], Never> {
        subject.eraseToAnyPublisher()
    }

    let selectionParamsHolder: SelectionParamsHolder

    init(selectionParamsHolder: SelectionParamsHolder) {
        self.selectionParamsHolder = selectionParamsHolder
        photoLibraryChangePermissionPublisher
            .sink { [weak self] in
                self?.reload()
            }
            .store(in: &subscriptions)
    }

    func reload() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        let assets = MediasProvider.map(fetchResult: allPhotos, mediaSelectionType: selectionParamsHolder.mediaType)

        DispatchQueue.main.async { [weak self] in
            self?.subject.send(assets)
        }
    }
}
