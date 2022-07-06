//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectableView<Content>: View where Content: View {
    let selected: Int?
    let onSelect: () -> Void
    @ViewBuilder let content: () -> Content
    
    @Environment(\.mediaSelectionStyle) private var mediaSelectionStyle
    
    var body: some View {
        ZStack(alignment: selectionAlignment) {
            content()

            Button {
                onSelect()
            } label: {
                SelectIndicatorView(index: selected)
            }
            .padding(4)
        }
    }
}

private extension SelectableView {
    var selectionAlignment: Alignment {
        switch mediaSelectionStyle {
        case .checkmark:
            return .bottomTrailing
        case .count:
            return .topTrailing
        }
    }
}
