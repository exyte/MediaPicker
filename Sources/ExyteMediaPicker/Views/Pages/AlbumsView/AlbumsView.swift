//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI
import Combine

struct AlbumsView: View {

    @EnvironmentObject private var selectionService: SelectionService
    @EnvironmentObject private var permissionsService: PermissionsService

    @StateObject var viewModel: AlbumsViewModel
    @Binding var showingCamera: Bool
    var selectionParamsHolder: SelectionParamsHolder

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0, alignment: .top)]
    }
    
    private var cellPadding: EdgeInsets {
        EdgeInsets(top: 2, leading: 2, bottom: 8, trailing: 2)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if let action = permissionsService.photoLibraryAction {
                    PermissionsActionView(action: .library(action))
                }
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.albums.isEmpty {
                    Text("Empty data")
                        .font(.title3)
                } else {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.albums) { album in
                            NavigationLink {
                                AlbumView(
                                    viewModel: AlbumViewModel(
                                        mediasProvider: AlbumMediasProvider(album: album, selectionParamsHolder: selectionParamsHolder)
                                    ),
                                    showingCamera: $showingCamera,
                                    shouldShowCamera: false,
                                    selectionParamsHolder: selectionParamsHolder
                                )
                            } label: {
                                AlbumCell(
                                    viewModel: AlbumCellViewModel(album: album)
                                )
                                .padding(cellPadding)
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
