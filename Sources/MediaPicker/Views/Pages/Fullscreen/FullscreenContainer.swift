//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI

struct FullscreenContainer: View {

    @Binding var isPresented: Bool
    let medias: [AssetMediaModel]
    @State var selection: AssetMediaModel.ID

    @Environment(\.mediaPickerTheme) private var theme

    @EnvironmentObject private var selectionService: SelectionService
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(medias, id: \.id) { media in
                ZStack {
                    let index = selectionService.index(of: media)
                    SelectableView(selected: index, paddings: 20, isFullscreen: true) {
                        selectionService.onSelect(media: media)
                    } content: {
                        FullscreenCell(viewModel: FullscreenCellViewModel(media: media))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .tag(media.id)

                    closeButton
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .background(theme.main.fullscreenBackground)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
    }
}
