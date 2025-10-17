//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumsView: View {

    @EnvironmentObject private var selectionService: SelectionService
    @Environment(\.mediaPickerTheme) private var theme

    @StateObject var viewModel: AlbumsViewModel
    @ObservedObject var mediaPickerViewModel: MediaPickerViewModel
    @ObservedObject var permissionsService = PermissionsService.shared

    @Binding var showingCamera: Bool
    @Binding var currentFullscreenMedia: Media?

    let selectionParamsHolder: SelectionParamsHolder
    let mediaPickerParamsHolder: MediaPickerParamsHolder
    let filterClosure: MediaPicker.FilterClosure?
    let massFilterClosure: MediaPicker.MassFilterClosure?

    @State private var showingLoadingCell = false
    
    private var cellPadding: EdgeInsets {
        EdgeInsets(top: 2, leading: 2, bottom: 8, trailing: 2)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                PermissionActionView(type: .library(permissionsService.photoLibraryPermissionStatus))

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if viewModel.albums.isEmpty {
                    Text("Empty data")
                        .font(.title3)
                        .foregroundColor(theme.main.pickerText)
                } else {
                    let (columnWidth, columns) = calculateColumnWidth(spacing: 0)
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.albums) { album in
                            AlbumCell(viewModel: AlbumCellViewModel(album: album), size: columnWidth)
                                .padding(cellPadding)
                                .onTapGesture {
                                    mediaPickerViewModel.setPickerMode(.album(album.toAlbum()))
                                }
                        }
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}
