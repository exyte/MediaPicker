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

    @State var availableFrame: CGRect = .zero

    var body: some View {
        VStack {
            Spacer()
            if let image = viewModel.image {
                if !keyboardHeightHelper.keyboardDisplayed {
                    ZoomableScrollView {
                        imageView(image: image)
                    }
                } else {
                    imageView(image: image)
                        .padding(.vertical, calculatePadding(imageSize: image.size, availableSize: availableFrame.size))
                }
            } else if let player = viewModel.player {
                if !keyboardHeightHelper.keyboardDisplayed {
                    ZoomableScrollView {
                        videoView(player: player)
                    }
                } else {
                    videoView(player: player)
                        .padding(.vertical, calculatePadding(imageSize: viewModel.videoSize, availableSize: availableFrame.size))
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.size.width)
        .frameGetter($availableFrame)
        .task {
            await viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }

    func imageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
    }

    func videoView(player: AVPlayer) -> some View {
        PlayerView(player: player, bgColor: theme.main.fullscreenPhotoBackground)
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

    func calculatePadding(imageSize: CGSize, availableSize: CGSize) -> CGFloat {
        let ratio = imageSize.width / imageSize.height
        let height = UIScreen.main.bounds.size.width / ratio
        let extra = availableSize.height - height
        print(availableSize, extra)
        return extra > 0 ? 0 : extra / 2 - 6
    }
}
