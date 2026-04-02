//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectableView<Content>: View where Content: View {

    var selected: Int?
    var isFullscreen: Bool
    var canSelect: Bool
    var selectionParameters: SelectionParameters
    var onSelect: () -> Void
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        content()
            .overlay(alignment: .topTrailing) {
                SelectionIndicatorView(index: selected, isFullscreen: isFullscreen, canSelect: canSelect, selectionParameters: selectionParameters)
                    .padding([.bottom, .leading], 10) // extend tappable area where possible
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect()
                    }
                    .padding(2)
            }
    }
}
