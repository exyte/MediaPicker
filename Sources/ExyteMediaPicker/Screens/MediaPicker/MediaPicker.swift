//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI

public struct MediaPicker<AlbumSelectionContent: View, CameraSelectionContent: View, CameraViewContent: View>: View {

    /// To provide custom buttons layout for photos grid view use actions and views provided by this closure:
    /// - standard header with photos/albums switcher
    /// - selection view you can embed in your view
    /// - is in fullscreen photo details mode
    public typealias AlbumSelectionClosure = ((ModeSwitcher, AlbumSelectionView, Bool) -> AlbumSelectionContent)

    /// To provide custom buttons layout for camera selection view use actions and views provided by this closure:
    /// - add more photos closure
    /// - cancel closure
    /// - selection view you can embed in your view
    public typealias CameraSelectionClosure = ((@escaping SimpleClosure, @escaping SimpleClosure, CameraSelectionView) -> CameraSelectionContent)

    /// To provide custom buttons layout for camera  view use actions and views provided by this closure:
    /// - live camera capture view
    /// - cancel closure
    /// - show preview of taken photos
    /// - take photo closure
    /// - start record video closure
    /// - stop record video closure
    /// - flash off/on closure
    /// - camera back/front closure
    public typealias CameraViewClosure = ((LiveCameraView, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure) -> CameraViewContent)

    public typealias FilterClosure = @Sendable (Media) async -> Media?
    public typealias MassFilterClosure = @Sendable ([Media]) async -> [Media]

    // MARK: - Parameters

    @Binding private var isPresented: Bool
    private let onChange: MediaPickerCompletionClosure

    // MARK: - View builders

    private var albumSelectionBuilder: AlbumSelectionClosure? = nil
    private var cameraSelectionBuilder: CameraSelectionClosure? = nil
    private var cameraViewBuilder: CameraViewClosure? = nil

    // MARK: - Customization

    @Binding private var albums: [Album]
    @Binding private var fullscreenMediaBinding: Media?
    private var pickerMode: Binding<MediaPickerMode>?
    private var selectedMedia: Binding<[Media]>?

    var mediaPickerParams = MediaPickerCutomizationParameters()

    // MARK: - Inner values

    @Environment(\.mediaPickerTheme) private var theme

    @StateObject private var viewModel = MediaPickerViewModel()
    @StateObject private var selectionService = SelectionService()
    @StateObject private var cameraSelectionService = CameraSelectionService()

    @State private var readyToShowCamera = false
    @State private var fullscreenMedia: Media?

    @State private var internalPickerMode: MediaPickerMode = .photos // a hack for slow camera dismissal

    var isInFullscreen: Bool {
        fullscreenMedia != nil
    }

    // MARK: - Object life cycle

    public init(isPresented: Binding<Bool>,
                onChange: @escaping MediaPickerCompletionClosure,
                albumSelectionBuilder: AlbumSelectionClosure? = nil,
                cameraSelectionBuilder: CameraSelectionClosure? = nil,
                cameraViewBuilder: CameraViewClosure? = nil) {

        self._isPresented = isPresented
        self._albums = .constant([])
        self._fullscreenMediaBinding = .constant(nil)

        self.onChange = onChange
        self.albumSelectionBuilder = albumSelectionBuilder
        self.cameraSelectionBuilder = cameraSelectionBuilder
        self.cameraViewBuilder = cameraViewBuilder
    }

    public var body: some View {
        Group {
            switch internalPickerMode { // please don't use viewModel.internalPickerMode here - it slows down camera dismissal
                case .photos, .albums, .album(_):
                    albumSelectionContainer
                case .camera:
                    cameraContainer
                case .cameraSelection:
                    cameraSelectionContainer
                }
        }
        .background(theme.main.pickerBackground.ignoresSafeArea())
        .environmentObject(selectionService)
        .environmentObject(cameraSelectionService)
        .onAppear {
            initialSetup()
            viewModel.onStart()
        }
        .onChange(of: selectionService.selected) { _ , selectedMedia in
            let selected: [Media] = selectedMedia.compactMap {
                guard $0.mediaType != nil else {
                    return nil
                }
                return Media(source: $0)
            }

            self.selectedMedia?.wrappedValue = selected
            onChange(selected)
        }
        .onChange(of: viewModel.albums) { _ , albums in
            self.albums = albums.map { $0.toAlbum() }
        }
        .onChange(of: pickerMode?.wrappedValue) { _ , mode in
            if let mode = mode {
                viewModel.setPickerMode(mode)
            }
        }
        .onChange(of: viewModel.internalPickerMode) { _ , newValue in
            internalPickerMode = newValue
        }
        .onChange(of: fullscreenMedia) { 
            _fullscreenMediaBinding.wrappedValue = fullscreenMedia
        }
    }

    func initialSetup() {
        // permissions
        PermissionsService.shared.updatePhotoLibraryAuthorizationStatus()
#if !targetEnvironment(simulator)
        if mediaPickerParams.liveCameraStyle != .none {
            PermissionsService.shared.requestCameraPermission()
        } else {
            PermissionsService.shared.updateCameraAuthorizationStatus()
        }
#endif

        // selection services
        if let selectedMedia {
            let initialSelection = selectedMedia.wrappedValue.compactMap { $0.source as? AssetMediaModel }
            selectionService.setInitialSelection(initialSelection)
        }
        selectionService.mediaSelectionLimit = mediaPickerParams.selectionParameters.selectionLimit

        cameraSelectionService.onChange = onChange
        cameraSelectionService.mediaSelectionLimit = mediaPickerParams.selectionParameters.selectionLimit

        // picker mode
        if let mode = pickerMode?.wrappedValue {
            viewModel.setPickerMode(mode)
        }
        viewModel.shouldUpdatePickerMode = { mode in
            pickerMode?.wrappedValue = mode
        }
    }

    @ViewBuilder
    var albumSelectionContainer: some View {
        let albumSelectionView = AlbumSelectionView(viewModel: viewModel, showingCamera: cameraBinding(), fullscreenMedia: $fullscreenMedia, mediaPickerParams: mediaPickerParams) {
            // has media limit of 1, and it's been selected
            isPresented = false
        }

        if let albumSelectionBuilder = albumSelectionBuilder {
            albumSelectionBuilder(ModeSwitcher(selection: modeBinding()), albumSelectionView, isInFullscreen)
        } else {
            VStack(spacing: 0) {
                defaultHeaderView
                albumSelectionView
            }
        }
    }

    @ViewBuilder
    var cameraSelectionContainer: some View {
        Group {
            if let cameraSelectionBuilder = cameraSelectionBuilder {
                cameraSelectionBuilder(
                    { viewModel.setPickerMode(.camera) }, // add more
                    { viewModel.onCancelCameraSelection(cameraSelectionService.hasSelected) }, // cancel
                    CameraSelectionView(selectionParameters: mediaPickerParams.selectionParameters)
                )
            } else {
                DefaultCameraSelectionContainer(
                    viewModel: viewModel,
                    showingPicker: $isPresented,
                    selectionParameters: mediaPickerParams.selectionParameters
                )
            }
        }
        .confirmationDialog("", isPresented: $viewModel.showingExitCameraConfirmation, titleVisibility: .hidden) {
            deleteAllButton
        }
    }

    @ViewBuilder
    var cameraContainer: some View {
        ZStack {
            theme.main.cameraBackground
                .ignoresSafeArea(.all)
                .onAppear {
                    DispatchQueue.main.async {
                        readyToShowCamera = true
                    }
                }
                .onDisappear {
                    readyToShowCamera = false
                }
            if readyToShowCamera {
                cameraSheet() {
                    // did take picture
                    if !cameraSelectionService.hasSelected {
                        viewModel.setPickerMode(.cameraSelection)
                    }
                    guard let url = viewModel.pickedMediaUrl else { return }
                    cameraSelectionService.onSelect(media: URLMediaModel(url: url))
                    viewModel.pickedMediaUrl = nil
                } didPressCancel: {
                    if let didPressCancel = mediaPickerParams.didPressCancelCamera {
                        didPressCancel()
                    } else {
                        viewModel.setPickerMode(.photos)
                    }
                }
                .confirmationDialog("", isPresented: $viewModel.showingExitCameraConfirmation, titleVisibility: .hidden) {
                    deleteAllButton
                }
            }
        }
        .onAppear {
            mediaPickerParams.orientationHandler(.lock)
        }
        .onDisappear {
            mediaPickerParams.orientationHandler(.unlock)
        }
    }

    var deleteAllButton: some View {
        Button("Delete All") {
            cameraSelectionService.removeAll()
            viewModel.setPickerMode(.photos)
        }
    }

    var defaultHeaderView: some View {
        HStack {
            Button("Cancel") {
                selectionService.removeAll()
                cameraSelectionService.removeAll()
                isPresented = false
            }

            Spacer()

            Picker("", selection:
                    Binding(
                        get: { viewModel.internalPickerMode == .albums ? 1 : 0 },
                        set: { value in
                            viewModel.setPickerMode(value == 0 ? .photos : .albums)
                        }
                    )
            ) {
                Text("Photos")
                    .tag(0)
                Text("Albums")
                    .tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: UIScreen.main.bounds.width / 2)

            Spacer()

            Button("Done") {
                if selectionService.selected.isEmpty, let current = fullscreenMedia {
                    onChange([current])
                }
                isPresented = false
            }
        }
        .foregroundColor(theme.main.pickerText)
        .padding(12)
        .background(theme.defaultHeader.background)
    }

    func cameraBinding() -> Binding<Bool> {
        Binding(
            get: { viewModel.internalPickerMode == .camera },
            set: { value in
                if value { viewModel.setPickerMode(.camera) }
            }
        )
    }

    func modeBinding() -> Binding<Int> {
        Binding(
            get: { viewModel.internalPickerMode == .albums ? 1 : 0 },
            set: { value in
                viewModel.setPickerMode(value == 0 ? .photos : .albums)
            }
        )
    }

    @ViewBuilder
    func cameraSheet(didTakePicture: @escaping ()->(), didPressCancel: @escaping ()->()) -> some View {
#if targetEnvironment(simulator)
        CameraStubView {
            didPressCancel()
        }
#elseif os(iOS)
        Group {
            if let cameraViewBuilder = cameraViewBuilder {
                CustomCameraView<CameraViewContent>(viewModel: viewModel, didTakePicture: didTakePicture, didPressCancel: didPressCancel, cameraViewBuilder: cameraViewBuilder)
                    .ignoresSafeArea()
            } else {
                StandardConrolsCameraView(viewModel: viewModel, didTakePicture: didTakePicture, didPressCancel: didPressCancel, selectionParameters: mediaPickerParams.selectionParameters)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            PermissionsService.shared.requestCameraPermission()
        }
#endif
    }
}

// MARK: - Bindings customization

public extension MediaPicker {
    func fullscreenMedia(_ fullscreenMedia: Binding<Media?>) -> MediaPicker {
        var mediaPicker = self
        mediaPicker._fullscreenMediaBinding = fullscreenMedia
        return mediaPicker
    }

    func albums(_ albums: Binding<[Album]>) -> MediaPicker {
        var mediaPicker = self
        mediaPicker._albums = albums
        return mediaPicker
    }

    func pickerMode(_ mode: Binding<MediaPickerMode>) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.pickerMode = mode
        return mediaPicker
    }

    func selectedMedia(_ binding: Binding<[Media]>) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.selectedMedia = binding
        return mediaPicker
    }
}
