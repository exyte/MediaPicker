//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Photos
import SwiftUI

@MainActor
class BaseMediasProvider: ObservableObject {
    var mediaPickerParams: MediaPickerCutomizationParameters

    @Published var assetMediaModels = [AssetMediaModel]()
    private var privateAssetMediaModels: [AssetMediaModel] = []

    @Published var isLoading: Bool = false

    private var timerTask: Task<Void, Never>?
    private var cancellableTask: Task<Void, Never>?

    init(mediaPickerParams: MediaPickerCutomizationParameters) {
        self.mediaPickerParams = mediaPickerParams
    }

    func filterAndPublish(assets: [AssetMediaModel]) {
        cancellableTask?.cancel()

        if let filterClosure = mediaPickerParams.filterClosure {
            isLoading = true
            startPublishing()

            cancellableTask = Task { [weak self] in
                guard let self else { return }
                privateAssetMediaModels = []

                await withTaskGroup(of: AssetMediaModel?.self) { group in
                    for asset in assets {
                        group.addTask {
                            guard !Task.isCancelled else { return nil }
                            let media = await Task.detached(priority: .userInitiated) {
                                await filterClosure(Media(source: asset))
                            }.value
                            return media?.source as? AssetMediaModel
                        }
                    }

                    for await filteredMedia in group {
                        if Task.isCancelled { break }
                        if let model = filteredMedia {
                            self.privateAssetMediaModels.append(model)
                        }
                    }
                }

                stopPublishing()
                assetMediaModels = privateAssetMediaModels
                isLoading = false
            }
        } else if let massFilterClosure = mediaPickerParams.massFilterClosure {
            isLoading = true
            cancellableTask = Task { [weak self] in
                guard let self else { return }
                let result = await massFilterClosure(assets.map { Media(source: $0) })
                assetMediaModels = result.compactMap { $0.source as? AssetMediaModel }
                isLoading = false
            }
        } else {
            assetMediaModels = assets
        }
    }

    func startPublishing() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                assetMediaModels = privateAssetMediaModels
            }
        }
    }

    func stopPublishing() {
        timerTask?.cancel()
    }

    func reload() { }

    func cancel() {
        cancellableTask?.cancel()
        stopPublishing()
    }
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
