//
//  Created by Alex.M on 08.06.2022.
//

import Foundation
import SwiftUI
import Combine
import Photos

final class SelectionService: ObservableObject {

    var mediaSelectionLimit: Int?
    var onChange: MediaPickerCompletionClosure? = nil

    @Published private(set) var selected: [AssetMediaModel] = []

    var canSendSelected: Bool {
        !selected.isEmpty
    }

    var fitsSelectionLimit: Bool {
        if let selectionLimit = mediaSelectionLimit {
            return selected.count < selectionLimit
        }
        return true
    }

    func canSelect(media: AssetMediaModel) -> Bool {
        fitsSelectionLimit || selected.contains(media)
    }

    func onSelect(media: AssetMediaModel) {
        if let index = selected.firstIndex(of: media) {
            selected.remove(at: index)
        } else {
            if fitsSelectionLimit {
                selected.append(media)
            }
        }
        onChange?(mapToMedia())
    }

    func index(of media: AssetMediaModel) -> Int? {
        selected.firstIndex(of: media)
    }

    func mapToMedia() -> [Media] {
        selected
            .compactMap {
                guard let type = $0.mediaType else {
                    return nil
                }
                return Media(type: type, source: .media($0))
            }
    }
}

private extension SelectionService {

    func findAsset(identifier: String) -> Future<PHAsset?, Never> {
        Future { promise in
            let options = PHFetchOptions()
            let photos = PHAsset.fetchAssets(with: options)

            var result: PHAsset?

            photos.enumerateObjects { (asset, _, stop) in
                if asset.localIdentifier == identifier {
                    result = asset
                    stop.pointee = true
                }
            }
            promise(.success(result))
        }
    }
}
