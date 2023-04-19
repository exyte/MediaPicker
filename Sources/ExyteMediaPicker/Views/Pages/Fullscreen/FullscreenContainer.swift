//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI

struct FullscreenContainer: View {

    @EnvironmentObject private var selectionService: SelectionService
    @Environment(\.mediaPickerTheme) private var theme

    @Binding var isPresented: Bool
    let medias: [AssetMediaModel]
    @State var selection: AssetMediaModel.ID

    private var selectedMedia: AssetMediaModel? {
        medias.first { $0.id == selection }
    }

    private var selectionServiceIndex: Int? {
        guard let selectedMedia = selectedMedia else {
            return nil
        }
        return selectionService.index(of: selectedMedia)
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(medias, id: \.id) { media in
                FullscreenCell(viewModel: FullscreenCellViewModel(media: media))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(media.id)
            }
        }
        .overlay {
            SelectIndicatorView(index: selectionServiceIndex, isFullscreen: true)
                .padding([.bottom, .leading], 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(10)
        }
        .onTapGesture {
            if let selectedMedia = selectedMedia {
                selectionService.onSelect(media: selectedMedia)
            }
        }
        .overlay(closeButton)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .background(theme.main.fullscreenPhotoBackground)
    }

    var closeButton: some View {
        Button {
            isPresented = false
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .tint(theme.selection.fullscreenTint)
                .frame(width: 20, height: 20)
                .padding(.top, 22)
                .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
