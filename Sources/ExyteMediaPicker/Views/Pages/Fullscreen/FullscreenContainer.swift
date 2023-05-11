//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI

struct FullscreenContainer: View {

    @EnvironmentObject private var selectionService: SelectionService
    @Environment(\.mediaPickerTheme) private var theme

    @Binding var isPresented: Bool
    let assetMediaModels: [AssetMediaModel]
    @State var selection: AssetMediaModel.ID
    var selectionParamsHolder: SelectionParamsHolder

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
        .overlay {
            if let selectedMediaModel = selectedMediaModel {
                SelectIndicatorView(index: selectionServiceIndex, isFullscreen: true, canSelect: selectionService.canSelect(assetMediaModel: selectedMediaModel), selectionParamsHolder: selectionParamsHolder)
                    .padding([.horizontal, .bottom], 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectionService.onSelect(assetMediaModel: selectedMediaModel)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .onTapGesture {
            if let selectedMediaModel = selectedMediaModel, selectedMediaModel.mediaType == .image {
                selectionService.onSelect(assetMediaModel: selectedMediaModel)
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
                .tint(theme.selection.fullscreenTint)
                .frame(width: 20, height: 20)
        }
        .padding([.horizontal, .bottom], 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
