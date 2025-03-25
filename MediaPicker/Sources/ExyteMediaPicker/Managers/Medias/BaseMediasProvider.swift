//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import Photos
import SwiftUI

@MainActor
class BaseMediasProvider: ObservableObject {
    var selectionParamsHolder: SelectionParamsHolder
    var filterClosure: MediaPicker.FilterClosure?
    var massFilterClosure: MediaPicker.MassFilterClosure?

    @Published var assetMediaModels = [AssetMediaModel]()
    private var privateAssetMediaModels: [AssetMediaModel] = []

    @Published var isLoading: Bool = false

    private var timerTask: Task<Void, Never>?
    private var cancellableTask: Task<Void, Never>?
    private var cancellable: AnyCancellable?

    init(selectionParamsHolder: SelectionParamsHolder, filterClosure: MediaPicker.FilterClosure?, massFilterClosure: MediaPicker.MassFilterClosure?) {
        self.selectionParamsHolder = selectionParamsHolder
        self.filterClosure = filterClosure
        self.massFilterClosure = massFilterClosure
    }

    func filterAndPublish(assets: [AssetMediaModel]) {
        isLoading = true
        defer {
            isLoading = false
        }

        if let filterClosure = filterClosure {
            startPublishing()

            cancellableTask = Task { [weak self] in
                let serialQueue = DispatchQueue(label: "filterSerialQueue")
                self?.privateAssetMediaModels = [AssetMediaModel]()

                await withTaskGroup(of: AssetMediaModel?.self) { group in
                    for asset in assets {
                        group.addTask {
                            if Task.isCancelled { return nil }

                            let media = await Task.detached(priority: .userInitiated) {
                                return await filterClosure(Media(source: asset))
                            }.value

                            return media?.source as? AssetMediaModel
                        }
                    }

                    for await filteredMedia in group {
                        if let model = filteredMedia {
                            serialQueue.sync {
                                self?.privateAssetMediaModels.append(model)
                            }
                        }
                    }
                }

                self?.stopPublishing()
                DispatchQueue.main.async {
                    self?.assetMediaModels = self?.privateAssetMediaModels ?? []
                }
            }
        } else if let massFilterClosure = massFilterClosure {
            cancellableTask = Task { [weak self] in
                let result = await massFilterClosure(assets.map { Media(source: $0) })
                self?.assetMediaModels = result.compactMap { $0.source as? AssetMediaModel }
            }
        }
        else {
            DispatchQueue.main.async { [weak self] in
                self?.assetMediaModels = assets
            }
        }
    }

    func startPublishing() {
        // Start a task that runs every second
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

                await MainActor.run {
                    self.assetMediaModels = self.privateAssetMediaModels
                }
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
