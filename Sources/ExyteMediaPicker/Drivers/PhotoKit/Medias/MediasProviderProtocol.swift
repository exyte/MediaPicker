//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import Photos

protocol MediasProviderProtocol {
    var medias: AnyPublisher<[AssetMediaModel], Never> { get }

    func reload()
}

class MediasProvider {

    static func map(fetchResult: PHFetchResult<PHAsset>) -> [AssetMediaModel] {
        var medias: [AssetMediaModel] = []

        if fetchResult.count == 0 {
            return medias
        }

        for index in 0...(fetchResult.count - 1) {
            let asset = fetchResult[index]
            medias.append(AssetMediaModel(source: asset))
        }
        return medias
    }
}
