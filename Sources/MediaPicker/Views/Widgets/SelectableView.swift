//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectableView<Content>: View where Content: View {

    var selected: Int?
    var paddings: CGFloat = 2
    var isFullscreen: Bool
    let onSelect: () -> Void
    @ViewBuilder let content: () -> Content
    
    @Environment(\.mediaSelectionStyle) private var mediaSelectionStyle
    
    var body: some View {
        content().overlay {
            Button {
                onSelect()
            } label: {
                SelectIndicatorView(index: selected, isFullscreen: isFullscreen)
                    .padding([.bottom, .leading], 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(paddings)
        }
    }
}
