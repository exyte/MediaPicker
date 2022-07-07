//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI

struct FullscreenContainer: View {
    var medias: [MediaModel]
    @State var index: Int

    @Environment(\.mediaPickerTheme) private var theme

    @EnvironmentObject private var selectionService: SelectionService
    
    var body: some View {
        TabView(selection: $index) {
            ForEach(medias.enumerated().map({ $0 }), id: \.offset) { (index, media) in
                let index = selectionService.index(of: media)
                SelectableView(selected: index, paddings: 20) {
                    selectionService.onSelect(media: media)
                } content: {
                    FullscreenCell(viewModel: FullscreenCellViewModel(media: media))
                        .tag(index)
                        .frame(maxHeight: .infinity)
                }
                .padding(.vertical)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(theme.main.fullscreenBackground)
    }
}
