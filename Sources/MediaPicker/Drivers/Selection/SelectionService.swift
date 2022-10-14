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

    func canSelect(media: AssetMediaModel) -> Bool {
        selected.count < selectionLimit || selected.contains(media)
    }

    func onSelect(media: AssetMediaModel) {
        if let index = selected.firstIndex(of: media) {
            selected.remove(at: index)
        } else {
            if selected.count < selectionLimit {
                selected.append(media)
            }
        }
        onChange?(mapToMedia())
    }

//    func onSelect(assetIdentifier identifier: String) {
//        Task {
//            if let asset = await findAsset(identifier: identifier).value {
//                await MainActor.run { [asset] in
//                    onSelect(media: MediaModel(source: asset))
//                }
//            }
//        }
//    }

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
    
    var selectionLimit: Int {
        mediaSelectionLimit ?? 0
    }

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
