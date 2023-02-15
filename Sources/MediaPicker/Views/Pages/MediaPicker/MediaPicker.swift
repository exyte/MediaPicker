//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
import Combine

public struct MediaPicker<AlbumSelectionContent: View, CameraSelectionContent: View>: View {

    /// To provide custom buttons layout for photos grid view use actions and views provided by this closure:
    /// - standard header with photos/albums switcher
    /// - selection view you can embed in your view
    public typealias AlbumSelectionClosure = ((ModeSwitcher, AlbumSelectionView) -> AlbumSelectionContent)

    /// To provide custom buttons layout for camera selection view use actions and views by this closure:
    /// - add more photos closure
    /// - cancel closure
    /// - selection view you can embed in your view
    public typealias CameraSelectionClosure = ((@escaping SimpleClosure, @escaping SimpleClosure, CameraSelectionTabView) -> CameraSelectionContent)

    // MARK: - Parameters

    @Binding private var isPresented: Bool
    @Binding private var albums: [Album]

    private let mediaSelectionLimit: Int?
    private let onChange: MediaPickerCompletionClosure
    private let orientationHandler: MediaPickerOrientationHandler

    private var pickerMode: Binding<MediaPickerMode>?
    private var showingLiveCameraCell: Bool = false

    // MARK: - View builders

    private var albumSelectionBuilder: AlbumSelectionClosure? = nil
    private var cameraSelectionBuilder: CameraSelectionClosure? = nil

    // MARK: - Inner values

    @Environment(\.mediaPickerTheme) private var theme

    @StateObject private var viewModel = MediaPickerViewModel()
    @StateObject private var selectionService = SelectionService()
    @StateObject private var cameraSelectionService = CameraSelectionService()
    @StateObject private var permissionService = PermissionsService()

    // MARK: - Object life cycle

    public init(isPresented: Binding<Bool>,
                limit: Int? = nil,
                orientationHandler: MediaPickerOrientationHandler? = nil,
                onChange: @escaping MediaPickerCompletionClosure,
                albumSelectionBuilder: @escaping AlbumSelectionClosure,
                cameraSelectionBuilder: @escaping CameraSelectionClosure) {

        self._isPresented = isPresented
        self._albums = .constant([])

        self.mediaSelectionLimit = limit
        self.onChange = onChange
        self.orientationHandler = orientationHandler ?? { _ in }
        self.albumSelectionBuilder = albumSelectionBuilder
        self.cameraSelectionBuilder = cameraSelectionBuilder
    }

    public var body: some View {
        NavigationView {
            Group {
                switch viewModel.internalPickerMode {
                case .photos, .albums, .album(_):
                    albumSelectionContainer
                case .camera:
                    theme.main.albumSelectionBackground // show using fullScreenCover instead
                case .cameraSelection:
                    cameraSelectionContainer
                }
            }
            .fullScreenCover(isPresented: cameraBinding()) {
                cameraSheet() {
                    // did take picture
                    if !cameraSelectionService.hasSelected {
                        viewModel.setPickerMode(.cameraSelection)
                    }
                    guard let url = viewModel.pickedMediaUrl else { return }
                    cameraSelectionService.onSelect(media: URLMediaModel(url: url))
                    viewModel.pickedMediaUrl = nil
                }
                .confirmationDialog("", isPresented: $viewModel.showingExitCameraConfirmation, titleVisibility: .hidden) {
                    deleteAllButton
                }
            }
        }
        .background(theme.main.albumSelectionBackground.ignoresSafeArea())
        .environmentObject(selectionService)
        .environmentObject(cameraSelectionService)
        .environmentObject(permissionService)
        .onAppear {
            selectionService.mediaSelectionLimit = mediaSelectionLimit
            selectionService.onChange = onChange
            
            cameraSelectionService.mediaSelectionLimit = mediaSelectionLimit
            cameraSelectionService.onChange = onChange

            viewModel.shouldUpdatePickerMode = { mode in
                pickerMode?.wrappedValue = mode
            }
            viewModel.onStart()
        }
        .onReceive(viewModel.$internalPickerMode) { mode in
            orientationHandler(mode == .camera ? .lock : .unlock)
        }
        .onChange(of: viewModel.albums) {
            self.albums = $0.map { $0.toAlbum() }
        }
        .onChange(of: pickerMode?.wrappedValue) { mode in
            if let mode = mode {
                viewModel.setPickerMode(mode)
            }
        }
        .onAppear {
            if let mode = pickerMode?.wrappedValue {
                viewModel.setPickerMode(mode)
            }
        }
    }

    @ViewBuilder
    var albumSelectionContainer: some View {
        let albumSelectionView = AlbumSelectionView(viewModel: viewModel, showingCamera: cameraBinding(), showingLiveCameraCell: showingLiveCameraCell)

        if let albumSelectionBuilder = albumSelectionBuilder {
            albumSelectionBuilder(ModeSwitcher(selection: modeBinding()), albumSelectionView)
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
                    CameraSelectionTabView()
                )
            } else {
                CameraSelectionContainer(viewModel: viewModel, showingPicker: $isPresented)
            }
        }
        .confirmationDialog("", isPresented: $viewModel.showingExitCameraConfirmation, titleVisibility: .hidden) {
            deleteAllButton
        }
    }

    var deleteAllButton: some View {
        Button("Delete All") {
            cameraSelectionService.removeAll()
            viewModel.setPickerMode(.photos)
            onChange(selectionService.mapToMedia())
        }
    }

    var defaultHeaderView: some View {
        HStack {
            Button("Cancel") {
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
                isPresented = false
            }
        }
        .padding(12)
        .background(Color(uiColor: .systemGroupedBackground))
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

    func cameraSheet(didTakePicture: @escaping ()->()) -> some View {
#if targetEnvironment(simulator)
        CameraStubView(isPresented: cameraBinding())
#elseif os(iOS)
        CameraView(viewModel: viewModel, didTakePicture: didTakePicture)
            .ignoresSafeArea()
#endif
    }
}

// MARK: - Customization

public extension MediaPicker {

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

    func showLiveCameraCell() -> MediaPicker {
        var mediaPicker = self
        mediaPicker.showingLiveCameraCell = true
        return mediaPicker
    }
}

// MARK: - Partial genereic specification imitation

public extension MediaPicker where AlbumSelectionContent == EmptyView, CameraSelectionContent == EmptyView {

    init(isPresented: Binding<Bool>,
         limit: Int? = nil,
         orientationHandler: MediaPickerOrientationHandler? = nil,
         onChange: @escaping MediaPickerCompletionClosure) {

        self._isPresented = isPresented
        self._albums = .constant([])

        self.mediaSelectionLimit = limit
        self.onChange = onChange
        self.orientationHandler = orientationHandler ?? {_ in}
    }
}

public extension MediaPicker where AlbumSelectionContent == EmptyView {

    init(isPresented: Binding<Bool>,
         limit: Int? = nil,
         orientationHandler: MediaPickerOrientationHandler? = nil,
         onChange: @escaping MediaPickerCompletionClosure,
         cameraSelectionBuilder: @escaping CameraSelectionClosure) {

        self._isPresented = isPresented
        self._albums = .constant([])

        self.mediaSelectionLimit = limit
        self.onChange = onChange
        self.orientationHandler = orientationHandler ?? {_ in}
        self.cameraSelectionBuilder = cameraSelectionBuilder
    }
}

public extension MediaPicker where CameraSelectionContent == EmptyView {

    init(isPresented: Binding<Bool>,
         limit: Int? = nil,
         orientationHandler: MediaPickerOrientationHandler? = nil,
         onChange: @escaping MediaPickerCompletionClosure,
         albumSelectionBuilder: @escaping AlbumSelectionClosure) {

        self._isPresented = isPresented
        self._albums = .constant([])

        self.mediaSelectionLimit = limit
        self.onChange = onChange
        self.orientationHandler = orientationHandler ?? {_ in}
        self.albumSelectionBuilder = albumSelectionBuilder
    }
}
