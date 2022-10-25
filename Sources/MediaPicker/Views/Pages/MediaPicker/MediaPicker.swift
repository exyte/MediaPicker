//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
import Combine

public struct MediaPicker: View {

    // MARK: - Parameters

    @Binding private var isPresented: Bool
    @Binding private var pickerMode: MediaPickerMode
    @Binding private var albums: [AlbumModel]

    private let mediaSelectionLimit: Int?
    private let onChange: MediaPickerCompletionClosure
    private let orientationHandler: MediaPickerOrientationHandler

    // MARK: - Inner values

    @Environment(\.mediaPickerTheme) private var theme

    @StateObject private var viewModel = MediaPickerViewModel()
    @StateObject private var selectionService = SelectionService()
    @StateObject private var cameraSelectionService = CameraSelectionService()
    @StateObject private var permissionService = PermissionsService()


    // MARK: - Object life cycle

    public init(isPresented: Binding<Bool>,
                pickerMode: Binding<MediaPickerMode>,
                limit: Int? = nil,
                orientationHandler: @escaping MediaPickerOrientationHandler,
                onChange: @escaping MediaPickerCompletionClosure) {

        self._isPresented = isPresented
        self._pickerMode = pickerMode
        self._albums = .constant([])

        self.mediaSelectionLimit = limit
        self.onChange = onChange
        self.orientationHandler = orientationHandler
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                switch pickerMode {
                case .photos:
                    AlbumView(
                        shouldShowCamera: true,
                        showingCamera: $viewModel.showingCamera,
                        viewModel: AlbumViewModel(
                            mediasProvider: AllPhotosProvider()
                        )
                    )
                case .albums:
                    AlbumsView(
                        showingCamera: $viewModel.showingCamera,
                        viewModel: AlbumsViewModel(
                            albumsProvider: viewModel.defaultAlbumsProvider
                        )
                    )
                case .album(let album):
                    AlbumView(
                        shouldShowCamera: false,
                        showingCamera: $viewModel.showingCamera,
                        viewModel: AlbumViewModel(
                            mediasProvider: AlbumMediasProvider(
                                album: album
                            )
                        )
                    )
                    .id(album.id)
                }
            }
            .fullScreenCover(isPresented: $viewModel.showingCameraSelection) {
                CameraSelectionContainer(viewModel: viewModel, showingPicker: $isPresented)
                    .confirmationDialog("", isPresented: $viewModel.showingExitCameraConfirmation, titleVisibility: .hidden) {
                        deleteAllButton()
                    }
            }
            .fullScreenCover(isPresented: $viewModel.showingCamera) {
                cameraSheet() {
                    // did take picture
                    if !cameraSelectionService.hasSelected {
                        viewModel.showingCameraSelection = true
                        viewModel.showingCamera = false
                    }
                    guard let url = viewModel.pickedMediaUrl else { return }
                    cameraSelectionService.onSelect(media: URLMediaModel(url: url))
                    viewModel.pickedMediaUrl = nil
                }
                .confirmationDialog("", isPresented: $viewModel.showingExitCameraConfirmation, titleVisibility: .hidden) {
                    deleteAllButton()
                }
            }
        }
        .onChange(of: viewModel.albums) {
            self.albums = $0
        }
        .background(theme.main.background.ignoresSafeArea())
        .environmentObject(selectionService)
        .environmentObject(cameraSelectionService)
        .environmentObject(permissionService)
        .onAppear {
            selectionService.mediaSelectionLimit = mediaSelectionLimit
            selectionService.onChange = onChange
            
            cameraSelectionService.mediaSelectionLimit = mediaSelectionLimit
            cameraSelectionService.onChange = onChange
            viewModel.onStart()
        }
        .onReceive(viewModel.$showingCamera) {
            orientationHandler($0 ? .lock : .unlock)
        }
    }

    func deleteAllButton() -> some View {
        Button("Delete All") {
            cameraSelectionService.removeAll()
            viewModel.showingCamera = false
            viewModel.showingCameraSelection = false
        }
    }

    func cameraSheet(didTakePicture: @escaping ()->()) -> some View {
#if targetEnvironment(simulator)
        CameraStubView(isPresented: $viewModel.showingCamera)
#elseif os(iOS)
        CameraView(viewModel: viewModel, didTakePicture: didTakePicture)
            .ignoresSafeArea()
#endif
    }
}

// TODO use this model for public stuff
public struct Album {
    let title: String?
    let preview: AssetMediaModel?
}

extension MediaPicker {

    public func albums(_ albums: Binding<[AlbumModel]>) -> MediaPicker {
        var mediaPicker = self
        mediaPicker._albums = albums
        return mediaPicker
    }
}
