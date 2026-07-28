//
//  Created by Alex.M on 27.05.2022.
//

public enum LiveCameraCellStyle {
    case none
    case small // 1 cell in photos grid
    case prominant // 2 cell height
}

import SwiftUI
import AnchoredPopup

struct AlbumView: View {

    enum DisplayMode { case allPhotos, albumPhotos }

    private struct CellFramesKey: PreferenceKey {
        static var defaultValue: [AssetMediaModel.ID: CGRect] { [:] }
        static func reduce(value: inout [AssetMediaModel.ID: CGRect], nextValue: () -> [AssetMediaModel.ID: CGRect]) {
            value.merge(nextValue()) { $1 }
        }
    }

    @EnvironmentObject private var selectionService: SelectionService
    @Environment(\.mediaPickerTheme) private var theme

    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper.shared
    @ObservedObject var permissionsService = PermissionsService.shared

    @StateObject var viewModel: BaseMediasProvider
    @Binding var showingCamera: Bool
    @Binding var fullscreenMedia: Media?

    var displayMode: DisplayMode
    var mediaPickerParams: MediaPickerCutomizationParameters
    var dismiss: ()->()

    @State private var fullscreenMediaModelID: AssetMediaModel.ID?
    @State private var isDragSelecting = false
    @State private var cellFrames: [AssetMediaModel.ID: CGRect] = [:]

    var body: some View {
        content
            .onAppear {
                viewModel.reload()
            }
            .onDisappear {
                viewModel.cancel()
            }
    }

    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                PermissionActionView(type: .library(permissionsService.photoLibraryPermissionStatus))

                if mediaPickerParams.liveCameraStyle != .none, displayMode == .allPhotos {
                    PermissionActionView(type: .camera(permissionsService.cameraPermissionStatus))
                }

                switch viewModel.loadingState {
                case .loading:
                    ActivityIndicator()
                        .foregroundStyle(theme.selection.cellSelectedBackground)
                case .empty:
                    Text("Empty data")
                        .font(.title3)
                        .foregroundColor(theme.main.pickerText)
                case .content:
                    mediasGrid
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4)
                    .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
                    .onChanged { value in
                        guard selectionService.mediaSelectionLimit != 1,
                              case .second(true, let dragValue) = value,
                              let location = dragValue?.location
                        else { return }
                        if !isDragSelecting {
                            isDragSelecting = true
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        selectCellIfNeeded(at: location)
                    }
                    .onEnded { _ in
                        isDragSelecting = false
                    }
            )
        }
        .scrollDisabled(isDragSelecting)
        .background(theme.main.pickerBackground)
        .onPreferenceChange(CellFramesKey.self) { frames in
            cellFrames = frames
        }
        .onTapGesture {
            if keyboardHeightHelper.keyboardDisplayed {
                dismissKeyboard()
            }
        }
    }

    private func getLiveCameraCell() -> LiveCameraCellStyle {
        #if targetEnvironment(simulator)
        return .none
        #else
        return if permissionsService.cameraPermissionStatus == .unavailable {
            .none
        } else {
            mediaPickerParams.liveCameraStyle
        }
        #endif
    }

    var mediasGrid: some View {
        let liveCameraCell = getLiveCameraCell()
        return MediasGrid(data: viewModel.assetMediaModels, liveCameraCellStyle: liveCameraCell) {
#if !targetEnvironment(simulator)
            if permissionsService.cameraPermissionStatus == .authorized {
                LiveCameraCell {
                    showingCamera = true
                }
            } else {
                Color.clear.aspectRatio(1, contentMode: .fit)
            }
#endif
        } content: { assetMediaModel, index, cellSize in
            cellView(assetMediaModel, index, cellSize)
        } loadingCell: {
            if case .content(let isLoadingMore) = viewModel.loadingState, isLoadingMore {
                ZStack {
                    Color.white.opacity(0.5)
                    ProgressView()
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
        .onChange(of: viewModel.assetMediaModels) { _ , newValue in
            selectionService.updateSelection(with: newValue)
        }
    }

    @ViewBuilder
    func cellView(_ assetMediaModel: AssetMediaModel, _ index: Int, _ size: CGFloat) -> some View {
        let imageButton = Button {
            if keyboardHeightHelper.keyboardDisplayed {
                dismissKeyboard()
            }
            if !mediaPickerParams.selectionParameters.showFullscreenPreview { // select immediately
                selectionService.onSelect(assetMediaModel: assetMediaModel)
                if selectionService.mediaSelectionLimit == 1 {
                    dismiss()
                }
            } else if fullscreenMediaModelID == nil {
                fullscreenMediaModelID = assetMediaModel.id
            }
        } label: {
            let id = "fullscreen_photo_\(index)"
            MediaCell(viewModel: MediaViewModel(assetMediaModel: assetMediaModel), size: size)
                .applyIf(mediaPickerParams.selectionParameters.showFullscreenPreview) {
                    $0.useAsPopupAnchor(id: id) {
                        FullscreenContainer(
                            selectionService: selectionService,
                            fullscreenMedia: $fullscreenMedia,
                            fullscreenMediaModelID: $fullscreenMediaModelID,
                            animationID: id,
                            assetMediaModels: viewModel.assetMediaModels,
                            selectionParameters: mediaPickerParams.selectionParameters,
                            dismiss: dismiss
                        )
                    } customize: {
                        $0.displayMode(.sheet)
                            .closeOnTap(false)
                            .animation(.easeIn(duration: 0.2))
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            fullscreenMediaModelID = assetMediaModel.id
                        }
                    )
                }
        }
        .buttonStyle(MediaButtonStyle())
        .contentShape(Rectangle())
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: CellFramesKey.self,
                    value: [assetMediaModel.id: geo.frame(in: .global)]
                )
            }
        )

        if selectionService.mediaSelectionLimit == 1 {
            imageButton
        } else {
            imageButton
                .overlay(alignment: .topTrailing) {
                    SelectionIndicatorView(
                        index: selectionService.selectionIndex(assetMediaModel),
                        canSelect: selectionService.canSelect(assetMediaModel),
                        isFullscreen: false,
                        selectionParameters: mediaPickerParams.selectionParameters
                    )
                    .padding([.bottom, .leading], 10) // extend tappable area where possible
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectionService.onSelect(assetMediaModel: assetMediaModel)
                    }
                    .padding(2)
                }
        }
    }

    private func selectCellIfNeeded(at location: CGPoint) {
        for (id, frame) in cellFrames {
            if frame.contains(location),
               let model = viewModel.assetMediaModels.first(where: { $0.id == id }),
               selectionService.index(of: model) == nil {
                selectionService.onSelect(assetMediaModel: model)
                break
            }
        }
    }
}
