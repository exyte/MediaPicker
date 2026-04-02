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
    @Binding var currentFullscreenMedia: Media?

    var mediaPickerParams: MediaPickerCutomizationParameters
    var dismiss: ()->()

    public var body: some View {
        switch viewModel.internalPickerMode {
        case .photos:
            AlbumView(
                viewModel: AllMediasProvider(mediaPickerParams: mediaPickerParams),
                showingCamera: $showingCamera,
                currentFullscreenMedia: $currentFullscreenMedia,
                displayMode: .allPhotos,
                mediaPickerParams: mediaPickerParams,
                dismiss: dismiss
            )
        case .albums:
            AlbumsView(
                viewModel: AlbumsViewModel(albumsProvider: viewModel.defaultAlbumsProvider),
                mediaPickerViewModel: viewModel,
                mediaPickerParams: mediaPickerParams
            )
            .onAppear {
                viewModel.defaultAlbumsProvider.mediaSelectionType = mediaPickerParams.selectionParameters.mediaType
            }
        case .album(let album):
            if let albumModel = viewModel.getAlbumModel(album) {
                AlbumView(
                    viewModel: AlbumMediasProvider(album: albumModel, mediaPickerParams: mediaPickerParams),
                    showingCamera: $showingCamera,
                    currentFullscreenMedia: $currentFullscreenMedia,
                    displayMode: .albumPhotos,
                    mediaPickerParams: mediaPickerParams,
                    dismiss: dismiss
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
