//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import Photos
import SwiftUI

protocol MediasProviderProtocol {
    var assetMediaModels: AnyPublisher<[AssetMediaModel], Never> { get }
    func reload()
}

class MediasProvider {

    static func map(fetchResult: PHFetchResult<PHAsset>, mediaSelectionType: MediaSelectionType) -> [AssetMediaModel] {
        var assetMediaModels: [AssetMediaModel] = []

        if fetchResult.count == 0 {
            return assetMediaModels
        }

        for index in 0...(fetchResult.count - 1) {
            let asset = fetchResult[index]
            if (asset.mediaType == .image && mediaSelectionType.allowsPhoto) || (asset.mediaType == .video && mediaSelectionType.allowsVideo) {
                assetMediaModels.append(AssetMediaModel(asset: asset))
            }
        }
        return assetMediaModels
    }
}
