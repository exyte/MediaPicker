//
//  Created by Alex.M on 07.06.2022.
//

import Foundation

@MainActor
final class AlbumsViewModel: ObservableObject {

    var albums: [AlbumModel] {
        albumsProvider.albums
    }

    var isLoading: Bool {
        albumsProvider.isLoading
    }

    private let albumsProvider: DefaultAlbumsProvider

    init(albumsProvider: DefaultAlbumsProvider) {
        self.albumsProvider = albumsProvider
    }

    func onStart() {
        albumsProvider.reload()
    }
    
    func onStop() {
        albumsProvider.cancelReload()
    }
}
