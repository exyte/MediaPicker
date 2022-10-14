//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI

public struct MediaPicker<L: View, R: View>: View {

    @Binding public var isPresented: Bool

    @StateObject private var viewModel = MediaPickerViewModel()
    @StateObject private var selectionService = SelectionService()
    @StateObject private var cameraSelectionService = CameraSelectionService()
    @StateObject private var permissionService = PermissionsService()

    private let mediaSelectionLimit: Int
    private let onChange: MediaPickerCompletionClosure?

    var leadingNavigation: (() -> L)? = nil
    var trailingNavigation: (() -> R)? = nil

    @Environment(\.mediaPickerTheme) private var theme

    // MARK: - Object life cycle
    public init(isPresented: Binding<Bool>,
                limit: Int = 10,
                leadingNavigation: @escaping () -> L,
                trailingNavigation: @escaping () -> R,
                onChange: @escaping MediaPickerCompletionClosure) {
        self._isPresented = isPresented
        self.mediaSelectionLimit = limit
        self.onChange = onChange

        self.leadingNavigation = leadingNavigation
        self.trailingNavigation = trailingNavigation
    }

    public init(isPresented: Binding<Bool>,
                limit: Int = 10,
                trailingNavigation: @escaping () -> R,
                onChange: @escaping MediaPickerCompletionClosure)
    where L == EmptyView {

        self._isPresented = isPresented
        self.mediaSelectionLimit = limit
        self.onChange = onChange

        self.trailingNavigation = trailingNavigation
    }

    public init(isPresented: Binding<Bool>,
                limit: Int = 10,
                leadingNavigation: @escaping () -> L,
                onChange: @escaping MediaPickerCompletionClosure)
    where R == EmptyView {

        self._isPresented = isPresented
        self.mediaSelectionLimit = limit
        self.onChange = onChange

        self.leadingNavigation = leadingNavigation
    }

    public init(isPresented: Binding<Bool>,
                limit: Int = 10,
                onChange: @escaping MediaPickerCompletionClosure)
    where L == EmptyView, R == EmptyView {

        self._isPresented = isPresented
        self.mediaSelectionLimit = limit
        self.onChange = onChange

        self.leadingNavigation = { EmptyView() }
        self.trailingNavigation = { EmptyView() }
    }

    // MARK: - SwiftUI View implementation
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Group {
                    switch viewModel.mode {
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
                                albumsProvider: DefaultAlbumsProvider()
                            )
                        )
                    }
                }
                .safeAreaInset(edge: .top, spacing: 0, content: {
                    headerView()
                        .padding(.vertical, 12)
                        .background(Material.regular)
                })
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
        }
    }
    
    private func headerView() -> some View {
        HStack {
            if let leadingNavigation = leadingNavigation?() {
                leadingNavigation
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Color.clear
                    .fixedSize(horizontal: false, vertical: true)
            }

            mediaPickerToolbar(mode: $viewModel.mode)

            if let trailingNavigation = trailingNavigation?() {
                trailingNavigation
                    .padding(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Color.clear
                    .fixedSize(horizontal: false, vertical: true)
            }
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
            .background(Color.black)
            .ignoresSafeArea()
#endif
    }
}
