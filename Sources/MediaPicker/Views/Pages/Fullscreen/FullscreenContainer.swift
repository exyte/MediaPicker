//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI

struct FullscreenContainer: View {

    let medias: [AssetMediaModel]
    @State var selection: AssetMediaModel.ID

    @Environment(\.mediaPickerTheme) private var theme

    @EnvironmentObject private var selectionService: SelectionService
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(medias, id: \.id) { media in
                let index = selectionService.index(of: media)
                SelectableView(selected: index, paddings: 20) {
                    selectionService.onSelect(media: media)
                } content: {
                    FullscreenCell(viewModel: FullscreenCellViewModel(media: media))
                }
                .tag(media.id)
            }
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(theme.main.fullscreenBackground)
        .ignoresSafeArea()
    }
}
