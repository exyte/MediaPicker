//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectIndicatorView: View {

    let index: Int?
    
    @Environment(\.mediaSelectionStyle) var mediaSelectionStyle
    @Environment(\.mediaPickerTheme) private var theme

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
}

private extension SelectIndicatorView {
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
                    .foregroundColor(theme.selection.emptyTint)
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
                    .foregroundColor(theme.selection.emptyTint)
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
                    SelectIndicatorView(index: nil)
                    SelectIndicatorView(index: 0)
                    SelectIndicatorView(index: 1)
                    SelectIndicatorView(index: 16)
                    SelectIndicatorView(index: 49)
                    SelectIndicatorView(index: 50)
                        .padding(4)
                        .background(Color.red)
                }
                VStack {
                    SelectIndicatorView(index: nil)
                    SelectIndicatorView(index: 0)
                    SelectIndicatorView(index: 1)
                    SelectIndicatorView(index: 16)
                    SelectIndicatorView(index: 49)
                    SelectIndicatorView(index: 50)
                        .padding(4)
                        .background(Color.red)
                }
                .environment(\.mediaSelectionStyle, .count)
            }
        }
    }
}
