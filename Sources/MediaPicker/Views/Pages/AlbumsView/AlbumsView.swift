//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI
import Combine

struct AlbumsView: View {

    @Binding var showingCamera: Bool
    @StateObject var viewModel: AlbumsViewModel

    @EnvironmentObject private var selectionService: SelectionService
    @EnvironmentObject private var permissionsService: PermissionsService

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
                                    shouldShowCamera: false,
                                    showingCamera: $showingCamera,
                                    viewModel: AlbumViewModel(
                                        mediasProvider: AlbumMediasProvider(
                                            album: album
                                        )
                                    )
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
