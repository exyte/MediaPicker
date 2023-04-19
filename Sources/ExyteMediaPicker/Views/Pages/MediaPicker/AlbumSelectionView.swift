//
//  AlbumSelectionView.swift
//  
//
//  Created by Alisa Mylnikova on 08.02.2023.
//

import SwiftUI

public struct AlbumSelectionView: View {

    @ObservedObject var viewModel: MediaPickerViewModel

    @Binding var showingCamera: Bool
    var showingLiveCameraCell: Bool = false

    public var body: some View {
        switch viewModel.internalPickerMode {
        case .photos:
            AlbumView(
                viewModel: AlbumViewModel(
                    mediasProvider: AllPhotosProvider()
                ),
                showingCamera: $showingCamera,
                shouldShowCamera: showingLiveCameraCell
            )
        case .albums:
            AlbumsView(
                viewModel: AlbumsViewModel(
                    albumsProvider: viewModel.defaultAlbumsProvider
                ),
                showingCamera: $showingCamera
            )
        case .album(let album):
            if let albumModel = viewModel.getAlbumModel(album) {
                AlbumView(
                    viewModel: AlbumViewModel(
                        mediasProvider: AlbumMediasProvider(album: albumModel)
                    ),
                    showingCamera: $showingCamera,
                    shouldShowCamera: false
                )
                .id(album.id)
            }
        default:
            EmptyView()
        }
    }
}

public struct ModeSwitcher: View {

    @Binding var selection: Int

    public var body: some View {
        Picker("", selection: $selection) {
            Text("Photos")
                .tag(0)
            Text("Albums")
                .tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: UIScreen.main.bounds.width / 2)
    }
}
