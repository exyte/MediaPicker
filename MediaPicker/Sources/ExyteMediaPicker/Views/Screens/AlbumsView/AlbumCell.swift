//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

struct AlbumCell: View {

    @Environment(\.mediaPickerTheme) private var theme

    @StateObject var viewModel: AlbumCellViewModel
    var size: CGFloat

    var body: some View {
        VStack {
            Rectangle()
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    ThumbnailView(preview: viewModel.preview, size: size)
                        .onAppear {
                            viewModel.fetchPreview(size: CGSize(width: size, height: size))
                        }
                }
                .clipped()
                .foregroundColor(theme.main.pickerBackground)

            if let title = viewModel.album.title {
                Text(title)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.main.pickerText)
            }
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}
