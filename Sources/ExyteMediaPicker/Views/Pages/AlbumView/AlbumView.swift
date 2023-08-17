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
    @Binding var isInFullscreen: Bool
    @Binding var currentFullscreenMedia: Media?

    var shouldShowCamera: Bool
    var shouldShowLoadingCell: Bool
    var selectionParamsHolder: SelectionParamsHolder
    var shouldDismiss: ()->()

    @State private var fullscreenItem: AssetMediaModel? {
        didSet {
            if let item = fullscreenItem {
                isInFullscreen = true
                currentFullscreenMedia = Media(source: item)
            } else {
                isInFullscreen = false
                currentFullscreenMedia = nil
            }
        }
    }

    var body: some View {
        if let title = viewModel.title {
            content.navigationTitle(title)
        } else {
            content
        }
    }
}

private extension AlbumView {

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
                } else if viewModel.assetMediaModels.isEmpty, !shouldShowLoadingCell {
                    Text("Empty data")
                        .font(.title3)
                } else {
                    MediasGrid(viewModel.assetMediaModels) {
#if !targetEnvironment(simulator)
                        if shouldShowCamera && permissionsService.cameraAction == nil {
                            LiveCameraCell {
                                showingCamera = true
                            }
                        }
#endif
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
                    } loadingCell: {
                        if shouldShowLoadingCell {
                            ZStack {
                                Color.white.opacity(0.5)
                                ProgressView()
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .onChange(of: viewModel.assetMediaModels) { newValue in 
                        selectionService.updateSelection(with: newValue)
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
                    selectionParamsHolder: selectionParamsHolder,
                    shouldDismiss: shouldDismiss
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
