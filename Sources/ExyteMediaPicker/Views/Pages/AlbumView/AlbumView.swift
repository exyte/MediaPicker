//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumView: View {

    @EnvironmentObject private var selectionService: SelectionService
    @EnvironmentObject private var permissionsService: PermissionsService
    @Environment(\.mediaPickerTheme) private var theme

    @StateObject var viewModel: AlbumViewModel
    @Binding var showingCamera: Bool
    var shouldShowCamera: Bool
    var selectionParamsHolder: SelectionParamsHolder

    @State private var fullscreenItem: AssetMediaModel?

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
                } else if viewModel.assetMediaModels.isEmpty {
                    Text("Empty data")
                        .font(.title3)
                } else {
                    MediasGrid(viewModel.assetMediaModels) {
                        if shouldShowCamera && permissionsService.cameraAction == nil {
                            LiveCameraCell {
                                showingCamera = true
                            }
                        }
                    } content: { assetMediaModel in
                        let index = selectionService.index(of: assetMediaModel)
                        SelectableView(selected: index, isFullscreen: false, canSelect: selectionService.canSelect(assetMediaModel: assetMediaModel), selectionParamsHolder: selectionParamsHolder) {
                            selectionService.onSelect(assetMediaModel: assetMediaModel)
                        } content: {
                            Button {
                                if fullscreenItem == nil {
                                    fullscreenItem = assetMediaModel
                                }
                            } label: {
                                MediaCell(viewModel: MediaViewModel(assetMediaModel: assetMediaModel))
                            }
                            .buttonStyle(MediaButtonStyle())
                            .contentShape(Rectangle())
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .background(theme.main.albumSelectionBackground)
        .overlay {
            if let item = fullscreenItem {
                FullscreenContainer(
                    isPresented: fullscreenPresentedBinding(),
                    assetMediaModels: viewModel.assetMediaModels,
                    selection: item.id,
                    selectionParamsHolder: selectionParamsHolder
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
