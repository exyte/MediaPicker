//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectIndicatorView: View {
    let index: Int?
    
    @Environment(\.mediaSelectionStyle) var mediaSelectionStyle
    
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
                Circle()
                    .fill(Color.white)
                    .overlay {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .foregroundColor(.blue)
                            .padding(2)
                    }
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .foregroundColor(.white)
            }
        }
    }
    
    var countView: some View {
        Group {
            if let index = index {
                Image(systemName: "\(index + 1).circle.fill")
                    .resizable()
            } else {
                Image(systemName: "circle")
                    .resizable()
            }
        }
        .foregroundColor(.blue)
        .background(Color.white)
        .cornerRadius(12)
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
