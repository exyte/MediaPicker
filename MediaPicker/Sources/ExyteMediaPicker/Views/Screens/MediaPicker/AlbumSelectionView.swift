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

    let showingLiveCameraCell: Bool
    let selectionParamsHolder: SelectionParamsHolder
    let filterClosure: MediaPicker.FilterClosure?
    let massFilterClosure: MediaPicker.MassFilterClosure?
    var dismiss: ()->()

    public var body: some View {
        switch viewModel.internalPickerMode {
        case .photos:
            AlbumView(
                viewModel: AllMediasProvider(selectionParamsHolder: selectionParamsHolder, filterClosure: filterClosure, massFilterClosure: massFilterClosure),
                showingCamera: $showingCamera,
                currentFullscreenMedia: $currentFullscreenMedia,
                shouldShowCamera: showingLiveCameraCell,
                selectionParamsHolder: selectionParamsHolder,
                dismiss: dismiss
            )
        case .albums:
            AlbumsView(
                viewModel: AlbumsViewModel(
                    albumsProvider: viewModel.defaultAlbumsProvider
                ),
                mediaPickerViewModel: viewModel,
                showingCamera: $showingCamera,
                currentFullscreenMedia: $currentFullscreenMedia,
                selectionParamsHolder: selectionParamsHolder,
                filterClosure: filterClosure,
                massFilterClosure: massFilterClosure
            )
            .onAppear {
                viewModel.defaultAlbumsProvider.mediaSelectionType = selectionParamsHolder.mediaType
            }
        case .album(let album):
            if let albumModel = viewModel.getAlbumModel(album) {
                AlbumView(
                    viewModel: AlbumMediasProvider(album: albumModel, selectionParamsHolder: selectionParamsHolder, filterClosure: filterClosure, massFilterClosure: massFilterClosure),
                    showingCamera: $showingCamera,
                    currentFullscreenMedia: $currentFullscreenMedia,
                    shouldShowCamera: false,
                    selectionParamsHolder: selectionParamsHolder,
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
