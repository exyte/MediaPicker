//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI
import AnchoredPopup

struct FullscreenContainer: View {

    @Environment(\.mediaPickerTheme) private var theme

    @ObservedObject var selectionService: SelectionService
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper.shared

    @Binding var fullscreenMedia: Media?
    @Binding var fullscreenMediaModelID: AssetMediaModel.ID?

    var animationID: String
    var assetMediaModels: [AssetMediaModel]
    var selectionParameters: SelectionParameters
    var dismiss: ()->()

    @State private var currentPageID: AssetMediaModel.ID?

    private var fullscreenMediaModel: AssetMediaModel? {
        assetMediaModels.first { $0.id == fullscreenMediaModelID }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { g in
                contentView(g.size)
                    .onTapGesture {
                        if keyboardHeightHelper.keyboardDisplayed {
                            dismissKeyboard()
                        } else {
                            if let fullscreenMediaModel, fullscreenMediaModel.mediaType == .image {
                                selectionService.onSelect(assetMediaModel: fullscreenMediaModel)
                            }
                        }
                    }
            }
            .ignoresSafeArea()
            .toolbar {
                backToolbarItem
                if let fullscreenMediaModel {
                    selectToolbarItem(fullscreenMediaModel)
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .background {
                theme.main.fullscreenPhotoBackground
                    .ignoresSafeArea()
            }
        }
        .tint(theme.selection.fullscreenSelectedBackground)
        .onAppear {
            currentPageID = fullscreenMediaModelID ?? ""
            if let fullscreenMediaModel {
                fullscreenMedia = Media(source: fullscreenMediaModel)
            }
        }
        .onDisappear {
            fullscreenMedia = nil
        }
        .onChange(of: fullscreenMediaModelID) {
            if let fullscreenMediaModel {
                fullscreenMedia = Media(source: fullscreenMediaModel)
            }
        }
    }

    var backToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(theme.selection.fullscreenSelectedBackground)
                .contentShape(Rectangle())
                .onTapGesture {
                    fullscreenMediaModelID = nil
                    AnchoredPopup.launchShrinkingAnimation(id: animationID)
                }
        }
    }

    func selectToolbarItem(_ fullscreenMediaModel: AssetMediaModel) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if selectionParameters.selectionLimit == 1 {
                Button("Select") {
                    AnchoredPopup.launchShrinkingAnimation(id: animationID)
                    selectionService.onSelect(assetMediaModel: fullscreenMediaModel)
                    dismiss()
                }
            } else {
                SelectionIndicatorView(
                    index: selectionService.index(of: fullscreenMediaModel),
                    canSelect: selectionService.canSelect(fullscreenMediaModel),
                    isFullscreen: true,
                    selectionParameters: selectionParameters
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectionService.onSelect(assetMediaModel: fullscreenMediaModel)
                }
            }
        }
    }

    @ViewBuilder
    func contentView(_ size: CGSize) -> some View {
        ScrollViewReader { scrollReader in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(assetMediaModels, id: \.id) { assetMediaModel in
                        FullscreenCell(viewModel: FullscreenCellViewModel(mediaModel: assetMediaModel))
                            .frame(width: size.width, height: size.height)
                            .id(assetMediaModel.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentPageID)
            .onChange(of: currentPageID) { _, newID in
                if let newID {
                    fullscreenMediaModelID = newID
                }
            }
            .onAppear {
                scrollReader.scrollTo(currentPageID)
            }
        }
    }

}
