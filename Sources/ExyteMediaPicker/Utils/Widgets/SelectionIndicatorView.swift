//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectionIndicatorView: View {

    @EnvironmentObject private var selectionService: SelectionService

    @Environment(\.mediaPickerTheme) var theme

    var index: Int?
    var isFullscreen: Bool
    var canSelect: Bool
    var selectionParamsHolder: SelectionParamsHolder

    var size: CGFloat { isFullscreen ? 26 : 24 }

    var emptyBorder: Color { isFullscreen ? theme.selection.fullscreenEmptyBorder : theme.selection.cellEmptyBorder }
    var emptyBackground: Color { isFullscreen ? theme.selection.fullscreenEmptyBackground : theme.selection.cellEmptyBackground }
    var selectedBorder: Color { isFullscreen ? theme.selection.fullscreenSelectedBorder : theme.selection.cellSelectedBorder }
    var selectedBackground: Color { isFullscreen ? theme.selection.fullscreenSelectedBackground : theme.selection.cellSelectedBackground }
    var selectedCheckmark: Color { isFullscreen ? theme.selection.fullscreenSelectedCheckmark : theme.selection.cellSelectedCheckmark }

    var body: some View {
        Group {
            switch selectionParamsHolder.selectionStyle {
            case .checkmark:
                checkView
            case .count:
                countView
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    var checkView: some View {
        if canSelect {
            let selected = index != nil
            ZStack {
                Circle().styled(
                    selected ? selectedBackground : emptyBackground,
                    border: selected ? selectedBorder : emptyBorder, 2
                )
                if index != nil {
                    Image(systemName: "checkmark")
                        .resizable()
                        .foregroundColor(selectedCheckmark)
                        .font(.system(size: 14, weight: .bold))
                        .padding(7)
                }
            }
            .animation(.easeOut(duration: 0.2), value: selected)
        }
    }

    @ViewBuilder
    var countView: some View {
        if canSelect {
            let selected = index != nil
            ZStack {
                Circle().styled(
                    selected ? selectedBackground : emptyBackground,
                    border: selected ? selectedBorder : emptyBorder, 2
                )
                if let index {
                    Text("\(index + 1)")
                        .foregroundColor(selectedCheckmark)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .animation(.easeOut(duration: 0.2), value: selected)
        }
    }
}
