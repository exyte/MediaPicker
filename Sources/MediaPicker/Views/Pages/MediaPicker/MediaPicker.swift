//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
import Combine

public struct MediaPicker: View {

    // MARK: - Parameters

    @Binding private var isPresented: Bool
    @Binding private var albums: [Album]

    private let mediaSelectionLimit: Int?
    private let onChange: MediaPickerCompletionClosure
    private let orientationHandler: MediaPickerOrientationHandler

    private var pickerMode: Binding<MediaPickerMode>?
    private var showingDefaultHeader: Bool = false
    private var showingLiveCameraCell: Bool = false

    // MARK: - Inner values

    @Environment(\.mediaPickerTheme) private var theme

    @StateObject private var viewModel = MediaPickerViewModel()
    @StateObject private var selectionService = SelectionService()
    @StateObject private var cameraSelectionService = CameraSelectionService()
    @StateObject private var permissionService = PermissionsService()

    @State private var internalPickerMode: MediaPickerMode = .photos
    @State private var internalPickerModeSelection = 0

    // MARK: - Object life cycle

    public init(isPresented: Binding<Bool>,
                limit: Int? = nil,
                orientationHandler: @escaping MediaPickerOrientationHandler,
                onChange: @escaping MediaPickerCompletionClosure) {

        self._isPresented = isPresented
        self._albums = .constant([])

        self.mediaSelectionLimit = limit
        self.onChange = onChange
        self.orientationHandler = orientationHandler
    }

    public init(isPresented: Binding<Bool>,
                limit: Int? = nil,
                onChange: @escaping MediaPickerCompletionClosure) {

        self._isPresented = isPresented
        self._albums = .constant([])

        self.mediaSelectionLimit = limit
        self.onChange = onChange
        self.orientationHandler = { _ in }
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingDefaultHeader {
                    defaultHeaderView
                        .padding(12)
                        .background(Color(uiColor: .systemGroupedBackground))
                }

                switch pickerMode?.wrappedValue ?? internalPickerMode {
                case .photos:
                    AlbumView(
                        shouldShowCamera: showingLiveCameraCell,
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
                    if let albumModel = viewModel.getAlbumModel(album) {
                        AlbumView(
                            shouldShowCamera: false,
                            showingCamera: $viewModel.showingCamera,
                            viewModel: AlbumViewModel(
                                mediasProvider: AlbumMediasProvider(
                                    album: albumModel
                                )
                            )
                        )
                        .id(album.id)
                    }
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
            self.albums = $0.map{ $0.toAlbum() }
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

    var defaultHeaderView: some View {
        HStack {
            Button("Cancel") {
                isPresented = false
            }

            Spacer()

            Picker("", selection: $internalPickerModeSelection) {
                Text("Photos")
                    .tag(0)
                Text("Albums")
                    .tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: UIScreen.main.bounds.width / 2)
            .onChange(of: internalPickerModeSelection) { newValue in
                internalPickerMode = newValue == 0 ? .photos : .albums
            }

            Spacer()

            Button("Done") {
                isPresented = false
            }
        }
    }
}

extension MediaPicker {

    public func albums(_ albums: Binding<[Album]>) -> MediaPicker {
        var mediaPicker = self
        mediaPicker._albums = albums
        return mediaPicker
    }

    public func pickerMode(_ mode: Binding<MediaPickerMode>) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.pickerMode = mode
        return mediaPicker
    }

    public func showDefaultHeader() -> MediaPicker {
        var mediaPicker = self
        mediaPicker.showingDefaultHeader = true
        return mediaPicker
    }

    public func showLiveCameraCell() -> MediaPicker {
        var mediaPicker = self
        mediaPicker.showingLiveCameraCell = true
        return mediaPicker
    }
}
