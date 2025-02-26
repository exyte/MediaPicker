//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI

struct FullscreenContainer: View {

    @EnvironmentObject private var selectionService: SelectionService
    @Environment(\.mediaPickerTheme) private var theme

    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper.shared

    @Binding var isPresented: Bool
    @Binding var currentFullscreenMedia: Media?
    let assetMediaModels: [AssetMediaModel]
    @State var selection: AssetMediaModel.ID?
    var selectionParamsHolder: SelectionParamsHolder
    var dismiss: ()->()

    private var selectedMediaModel: AssetMediaModel? {
        assetMediaModels.first { $0.id == selection }
    }

    private var selectionServiceIndex: Int? {
        guard let selectedMediaModel = selectedMediaModel else {
            return nil
        }
        return selectionService.index(of: selectedMediaModel)
    }

    var body: some View {
        VStack {
            controlsOverlay
            GeometryReader { g in
                let size = g.size
                contentView(size)
            }
        }
        .ignoresSafeArea()
        .background {
            theme.main.fullscreenPhotoBackground
                .ignoresSafeArea()
        }
        .onAppear {
            if let selectedMediaModel {
                currentFullscreenMedia = Media(source: selectedMediaModel)
            }
        }
        .onDisappear {
            currentFullscreenMedia = nil
        }
        .onChange(of: selection) { newValue in
            if let selectedMediaModel {
                currentFullscreenMedia = Media(source: selectedMediaModel)
            }
        }
        .onTapGesture {
            if keyboardHeightHelper.keyboardDisplayed {
                dismissKeyboard()
            } else {
                if let selectedMediaModel = selectedMediaModel, selectedMediaModel.mediaType == .image {
                    selectionService.onSelect(assetMediaModel: selectedMediaModel)
                }
            }
        }
    }

    @ViewBuilder
    func contentView(_ size: CGSize) -> some View {
        if #available(iOS 17.0, *) {
            ScrollViewReader { scrollReader in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(assetMediaModels, id: \.id) { assetMediaModel in
                            FullscreenCell(viewModel: FullscreenCellViewModel(mediaModel: assetMediaModel), size: size)
                                .frame(width: size.width, height: size.height)
                                .id(assetMediaModel.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $selection)
                .onAppear {
                    scrollReader.scrollTo(selection)
                }
            }
        } else {
            TabView(selection: $selection) {
                ForEach(assetMediaModels, id: \.id) { assetMediaModel in
                    FullscreenCell(viewModel: FullscreenCellViewModel(mediaModel: assetMediaModel), size: size)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(assetMediaModel.id)
                }
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
                    isPresented = false
                }

            Spacer()

            if let selectedMediaModel = selectedMediaModel {
                if selectionParamsHolder.selectionLimit == 1 {
                    Button("Select") {
                        selectionService.onSelect(assetMediaModel: selectedMediaModel)
                        dismiss()
                    }
                    .padding(.horizontal, 20)
                } else {
                    SelectionIndicatorView(index: selectionServiceIndex, isFullscreen: true, canSelect: selectionService.canSelect(assetMediaModel: selectedMediaModel), selectionParamsHolder: selectionParamsHolder)
                        .padding(.horizontal, 20)
                }
            }
        }
        .foregroundStyle(theme.selection.fullscreenSelectedBackground)
    }
}
