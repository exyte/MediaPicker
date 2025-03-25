//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct MediaCell: View {

    @Environment(\.mediaPickerTheme) private var theme

    @StateObject var viewModel: MediaViewModel
    var size: CGFloat

    var body: some View {
        ZStack {
            ThumbnailView(preview: viewModel.preview, size: size)
                .cornerRadius(theme.cellStyle.cornerRadius)
                .onAppear {
                    viewModel.onStart(size: size)
                }
                .aspectRatio(1, contentMode: .fill)
                .clipped()

            if let duration = viewModel.assetMediaModel.asset.formattedDuration {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top))
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.trailing, 4)
                            .padding(.bottom, 4)
                    }
                }
            }
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}
