//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI

public struct MediaPicker<L: View, R: View>: View {
    @Binding public var isPresented: Bool

    @StateObject private var viewModel = MediaPickerViewModel()
    @StateObject private var selectionService = SelectionService()
    @StateObject private var permissionService = PermissionsService()

    private let mediaSelectionLimit: Int
    private let onChange: MediaPickerCompletionClosure?

    var leadingNavigation: (() -> L)? = nil
    var trailingNavigation: (() -> R)? = nil

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

        self.leadingNavigation = { EmptyView() }
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
        self.trailingNavigation = { EmptyView() }
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
            VStack {
                switch viewModel.mode {
                case .photos:
                    AlbumView(
                        shouldShowCamera: true,
                        isShowCamera: $viewModel.showCamera,
                        viewModel: AlbumViewModel(
                            mediasProvider: AllPhotosProvider()
                        )
                    )
                case .albums:
                    AlbumsView(
                        isShowCamera: $viewModel.showCamera,
                        viewModel: AlbumsViewModel(
                            albumsProvider: DefaultAlbumsProvider()
                        )
                    )
                }
            }
            .mediaPickerNavigationBar(mode: $viewModel.mode) {
                isPresented = false
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    leadingNavigation?()
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    trailingNavigation?()
                }
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(selectionService)
        .environmentObject(permissionService)
        .onAppear {
            selectionService.mediaSelectionLimit = mediaSelectionLimit
            selectionService.onChange = onChange
        }
        .cameraSheet(isPresented: $viewModel.showCamera, pickedAssetId: $viewModel.pickedAssetId)
#if os(iOS)
        .onChange(of: viewModel.pickedAssetId) { newValue in
            guard let identifier = newValue
            else { return }

            selectionService.onSelect(assetIdentifier: identifier)
            viewModel.pickedAssetId = nil
        }
#endif
    }
}
