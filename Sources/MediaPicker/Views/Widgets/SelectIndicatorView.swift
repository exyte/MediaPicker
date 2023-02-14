//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectIndicatorView: View {

    @Environment(\.mediaSelectionStyle) var mediaSelectionStyle
    @Environment(\.mediaPickerTheme) var theme

    var index: Int?
    var isFullscreen: Bool

    var body: some View {
        Group {
            switch mediaSelectionStyle {
            case .checkmark:
                checkView
            case .count:
                countView
            }
        }
        .frame(width: 24, height: 24)
    }

    var checkView: some View {
        Group {
            if index != nil {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(theme.selection.selectedTint)
                    .padding(2)
                    .background {
                        Circle()
                            .fill(theme.selection.selectedBackground)
                    }
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .foregroundColor(isFullscreen ? theme.selection.fullscreenTint : theme.selection.emptyTint)
                    .background {
                        Circle()
                            .fill(theme.selection.emptyBackground)
                    }
            }
        }
    }
    
    var countView: some View {
        Group {
            if let index = index {
                Image(systemName: "\(index + 1).circle.fill")
                    .resizable()
                    .foregroundColor(theme.selection.selectedTint)
                    .background {
                        Circle()
                            .fill(theme.selection.selectedBackground)
                    }
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .foregroundColor(isFullscreen ? theme.selection.fullscreenTint : theme.selection.emptyTint)
                    .background {
                        Circle()
                            .fill(theme.selection.emptyBackground)
                    }
            }
        }
    }
}

struct SelectIndicatorView_Preview: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .fill(.green)
                .ignoresSafeArea()
            HStack {
                VStack {
                    SelectIndicatorView(index: nil, isFullscreen: false)
                    SelectIndicatorView(index: 0, isFullscreen: false)
                    SelectIndicatorView(index: 1, isFullscreen: false)
                    SelectIndicatorView(index: 16, isFullscreen: false)
                    SelectIndicatorView(index: 49, isFullscreen: false)
                    SelectIndicatorView(index: 50, isFullscreen: false)
                        .padding(4)
                        .background(Color.red)
                }
                VStack {
                    SelectIndicatorView(index: nil, isFullscreen: false)
                    SelectIndicatorView(index: 0, isFullscreen: false)
                    SelectIndicatorView(index: 1, isFullscreen: false)
                    SelectIndicatorView(index: 16, isFullscreen: false)
                    SelectIndicatorView(index: 49, isFullscreen: false)
                    SelectIndicatorView(index: 50, isFullscreen: false)
                        .padding(4)
                        .background(Color.red)
                }
                .environment(\.mediaSelectionStyle, .count)
            }
        }
    }
}
