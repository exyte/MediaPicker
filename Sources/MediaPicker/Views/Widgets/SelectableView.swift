//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectableView<Content>: View where Content: View {
    let selected: Int?
    let paddings: CGFloat
    let onSelect: () -> Void
    @ViewBuilder let content: () -> Content
    
    @Environment(\.mediaSelectionStyle) private var mediaSelectionStyle

    init(selected: Int?, paddings: CGFloat = 2, onSelect: @escaping () -> Void, content: @escaping () -> Content) {
        self.selected = selected
        self.paddings = paddings
        self.onSelect = onSelect
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: selectionAlignment) {
            content()

            Button {
                onSelect()
            } label: {
                SelectIndicatorView(index: selected)
            }
            .padding(paddings)
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
