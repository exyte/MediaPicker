//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumView: View {

    var shouldShowCamera: Bool
    @Binding var showingCamera: Bool
    @StateObject var viewModel: AlbumViewModel

    @State private var fullscreenItem: AssetMediaModel?
    
    @Environment(\.mediaPickerTheme) private var theme

    @EnvironmentObject private var selectionService: SelectionService
    @EnvironmentObject private var permissionsService: PermissionsService

    var body: some View {
        if let title = viewModel.title {
            content.navigationTitle(title)
        } else {
            content
        }
    }
}

private extension AlbumView {

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0)]
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack {
                if let action = permissionsService.photoLibraryAction {
                    PermissionsActionView(action: .library(action))
                }
                if shouldShowCamera, let action = permissionsService.cameraAction {
                    PermissionsActionView(action: .camera(action))
                }
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.medias.isEmpty {
                    Text("Empty data")
                        .font(.title3)
                } else {
                    MediasGrid(viewModel.medias) {
                        if shouldShowCamera && permissionsService.cameraAction == nil {
                            LiveCameraCell {
                                showingCamera = true
                            }
                        }
                    } content: { media in
                        let index = selectionService.index(of: media)
                        SelectableView(selected: index, isFullscreen: false) {
                            selectionService.onSelect(media: media)
                        } content: {
                            Button {
                                if fullscreenItem == nil {
                                    fullscreenItem = media
                                }
                            } label: {
                                MediaCell(viewModel: MediaViewModel(media: media))
                            }
                            .buttonStyle(MediaButtonStyle())
                            .contentShape(Rectangle())
                        }
                        .disabled(!selectionService.canSelect(media: media))
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .background(theme.main.background)
        .overlay {
            if let item = fullscreenItem {
                FullscreenContainer(
                    isPresented: fullscreenPresentedBinding(),
                    medias: viewModel.medias,
                    selection: item.id
                )
            }
        }
    }

    func fullscreenPresentedBinding() -> Binding<Bool> {
        Binding(
            get: { fullscreenItem != nil },
            set: { value in
                if value == false {
                    fullscreenItem = nil
                }
            }
        )
    }
}
