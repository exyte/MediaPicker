//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI
import AVKit

struct FullscreenCell: View {

    @StateObject var viewModel: FullscreenCellViewModel
    
    var body: some View {
        VStack {
            if viewModel.isImageSet, let image = viewModel.preview {
                ZoomableScrollView {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            } else if let player = viewModel.player {
                ZoomableScrollView {
                    VideoPlayer(player: player)
                        .padding()
                }
            } else {
                Spacer()
                ProgressView()
                    .tint(.white)
                Spacer()
            }
        }
        .task {
            await viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}
