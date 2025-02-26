//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI
import AVKit

struct FullscreenCell: View {
    
    @Environment(\.mediaPickerTheme) private var theme

    @StateObject var viewModel: FullscreenCellViewModel
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper.shared

    var size: CGSize

    var body: some View {
        Group {
            if let image = viewModel.image {
                ZoomableScrollView {
                    imageView(image: image, useFill: false)
                }
            } else if let player = viewModel.player {
                ZoomableScrollView {
                    videoView(player: player, useFill: false)
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .allowsHitTesting(!keyboardHeightHelper.keyboardDisplayed)
        .task {
            await viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }

    @ViewBuilder
    func imageView(image: UIImage, useFill: Bool) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: useFill ? .fill : .fit)
    }

    func videoView(player: AVPlayer, useFill: Bool) -> some View {
        PlayerView(player: player, bgColor: theme.main.fullscreenPhotoBackground, useFill: useFill)
            .disabled(true)
            .overlay {
                ZStack {
                    Color.clear
                    if !viewModel.isPlaying {
                        Circle().styled(.black.opacity(0.2))
                            .frame(width: 70, height: 70)
                        Image(systemName: "play.fill")
                            .resizable()
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 30, height: 30)
                            .padding(.leading, 4)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.togglePlay()
                }
            }
    }
}
