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
            if let image = viewModel.image {
                ZoomableScrollView {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            } else if let player = viewModel.player {
                ZoomableScrollView {
                    VideoPlayer(player: player)
                        .disabled(true)
                        .overlay {
                            ZStack {
                                Color.clear
                                if !viewModel.isPlaying {
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.togglePlay()
                            }
                        }
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
