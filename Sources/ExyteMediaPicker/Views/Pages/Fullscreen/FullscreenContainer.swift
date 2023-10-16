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
    @State var selection: AssetMediaModel.ID
    var selectionParamsHolder: SelectionParamsHolder
    var shouldDismiss: ()->()

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
        TabView(selection: $selection) {
            ForEach(assetMediaModels, id: \.id) { assetMediaModel in
                FullscreenCell(viewModel: FullscreenCellViewModel(mediaModel: assetMediaModel))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(assetMediaModel.id)
            }
        }
        .onChange(of: selection) { newValue in
            if let selectedMediaModel {
                currentFullscreenMedia = Media(source: selectedMediaModel)
            }
        }
        .overlay(alignment: .topTrailing) {
            if let selectedMediaModel = selectedMediaModel {
                if selectionParamsHolder.selectionLimit == 1 {
                    Button("Select") {
                        selectionService.onSelect(assetMediaModel: selectedMediaModel)
                        shouldDismiss()
                    }
                    .padding([.horizontal, .bottom], 20)
                } else {
                    SelectIndicatorView(index: selectionServiceIndex, isFullscreen: true, canSelect: selectionService.canSelect(assetMediaModel: selectedMediaModel), selectionParamsHolder: selectionParamsHolder)
                        .padding([.horizontal, .bottom], 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectionService.onSelect(assetMediaModel: selectedMediaModel)
                        }
                }
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
        .overlay(closeButton)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(
            theme.main.fullscreenPhotoBackground
                .ignoresSafeArea()
        )
    }

    var closeButton: some View {
        Button {
            isPresented = false
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 20, height: 20)
                .tint(theme.selection.fullscreenTint)
                .padding(12)
        }
        .padding([.horizontal, .bottom], 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
