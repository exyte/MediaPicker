//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

struct AssetMediaModel {
    let source: PHAsset
}

extension AssetMediaModel {

    var mediaType: MediaType? {
        switch source.mediaType {
        case .image:
            return .image
        case .video:
            return .video
        default:
            return nil
        }
    }
}

extension AssetMediaModel: Identifiable {
    var id: String {
        source.localIdentifier
    }
}

extension AssetMediaModel: Equatable {
    static func ==(lhs: AssetMediaModel, rhs: AssetMediaModel) -> Bool {
        lhs.id == rhs.id
    }
}
