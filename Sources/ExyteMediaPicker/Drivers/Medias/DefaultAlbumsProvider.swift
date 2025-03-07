//
//  Created by Alex.M on 10.06.2022.
//

import Foundation
import Photos

import Photos
import SwiftUI

@MainActor
final class DefaultAlbumsProvider: ObservableObject {

    @Published private(set) var albums: [AlbumModel] = []
    @Published private(set) var isLoading: Bool = false

    var mediaSelectionType: MediaSelectionType = .photoAndVideo
    private var reloadTask: Task<Void, Never>?

    func reload() {
        cancelReload()

        PermissionsService.requestPhotoLibraryPermission { [weak self] in
            guard let self = self else { return }
            self.reloadTask = Task {
                self.isLoading = true
                await self.reloadInternal()
                self.isLoading = false
            }
        }
    }

    func cancelReload() {
        reloadTask?.cancel()
        reloadTask = nil
    }

    private func reloadInternal() async {
        let albumTypes: [PHAssetCollectionType] = [.album, .smartAlbum]
        var allAlbums: [AlbumModel] = []

        for type in albumTypes {
            if Task.isCancelled { return }
            let albums = fetchAlbums(type: type)
            allAlbums.append(contentsOf: albums)
        }

        if Task.isCancelled { return }
        self.albums = allAlbums
    }

    private func fetchAlbums(type: PHAssetCollectionType) -> [AlbumModel] {
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = [.typeUserLibrary, .typeiTunesSynced, .typeCloudShared]
        options.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]

        let collections = PHAssetCollection.fetchAssetCollections(
            with: type,
            subtype: .any,
            options: options
        )

        guard collections.count > 0 else { return [] }

        var albums: [AlbumModel] = []

        for index in 0..<collections.count {
            if Task.isCancelled { return [] }

            let collection = collections[index]
            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            options.fetchLimit = 1

            let fetchResult = PHAsset.fetchAssets(in: collection, options: options)
            guard fetchResult.count > 0 else { continue }

            let preview = MediasProvider.map(fetchResult: fetchResult, mediaSelectionType: mediaSelectionType).first
            let album = AlbumModel(preview: preview, source: collection)
            albums.append(album)
        }
        return albums
    }
}
