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
        VStack {
            controlsOverlay
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
        }
        .safeAreaPadding(.top, UIApplication.safeArea.top)
        .background {
            theme.main.fullscreenPhotoBackground
                .ignoresSafeArea()
        }
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

    var controlsOverlay: some View {
        HStack {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(20, 16)
                .contentShape(Rectangle())
                .onTapGesture {
                    fullscreenMediaModelID = nil
                    AnchoredPopup.launchShrinkingAnimation(id: animationID)
                }

            Spacer()

            if let fullscreenMediaModel {
                if selectionParameters.selectionLimit == 1 {
                    Button("Select") {
                        AnchoredPopup.launchShrinkingAnimation(id: animationID)
                        selectionService.onSelect(assetMediaModel: fullscreenMediaModel)
                        dismiss()
                    }
                    .padding(.horizontal, 20)
                } else {
                    SelectionIndicatorView(
                        index: selectionService.index(of: fullscreenMediaModel),
                        canSelect: selectionService.canSelect(fullscreenMediaModel),
                        isFullscreen: true,
                        selectionParameters: selectionParameters
                    )
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectionService.onSelect(assetMediaModel: fullscreenMediaModel) // for video selection, since tap on video is toggle play
                    }
                }
            }
        }
        .foregroundStyle(theme.selection.fullscreenSelectedBackground)
    }
}
