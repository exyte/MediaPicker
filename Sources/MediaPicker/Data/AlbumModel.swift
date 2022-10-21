//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

public struct AlbumModel {
    let preview: AssetMediaModel?
    let source: PHAssetCollection
}

extension AlbumModel: Identifiable {
    public var id: String {
        source.localIdentifier
    }

    public var title: String? {
        source.localizedTitle
    }
}

extension AlbumModel: Equatable {}
