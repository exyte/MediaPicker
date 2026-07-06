//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
@preconcurrency import AVKit
import UIKit.UIImage

#if compiler(>=6.0)
extension AVAssetTrack: @retroactive @unchecked Sendable { }
#else
extension AVAssetTrack: @unchecked Sendable { }
#endif

@MainActor
final class FullscreenCellViewModel: ObservableObject {

    let mediaModel: MediaModelProtocol

    @Published var image: UIImage? = nil
    @Published var player: AVPlayer? = nil
    @Published var isPlaying = false
    @Published var videoSize: CGSize = .zero

    private var currentTask: Task<Void, Never>?

    init(mediaModel: MediaModelProtocol) {
        self.mediaModel = mediaModel
    }

    func onStart() async {
        currentTask?.cancel()
        currentTask = Task {
            switch self.mediaModel.mediaType {
            case .image:
                let data = try? await mediaModel.getData() // url is slow to load in UI, this way photos don't flicker when swiping
                guard let data else { return }
                image = UIImage(data: data)
            case .video:
                let url = await mediaModel.getURL()
                guard let url else { return }
                setupPlayer(url)
                videoSize = await getVideoSize(url)
            case .none:
                break
            }
        }
    }

    func setupPlayer(_ url: URL) {
        let avPlayer = AVPlayer(url: url)
        player = avPlayer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(finishVideo),
            name: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem
        )
    }

    @objc func finishVideo() {
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: 10))
        isPlaying = false
    }

    func onStop() {
        currentTask?.cancel()
        currentTask = nil
        NotificationCenter.default.removeObserver(self)
        image = nil
        player = nil
        isPlaying = false
    }

    func togglePlay() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying = !isPlaying
    }

    func getVideoSize(_ url: URL) async -> CGSize {
        let videoAsset = AVURLAsset(url : url)

        let videoAssetTrack = try? await videoAsset.loadTracks(withMediaType: .video).first
        let naturalSize = (try? await videoAssetTrack?.load(.naturalSize)) ?? .zero
        let transform = try? await videoAssetTrack?.load(.preferredTransform)
        if (transform?.tx == naturalSize.width && transform?.ty == naturalSize.height) || (transform?.tx == 0 && transform?.ty == 0) {
            return naturalSize
        } else {
            return CGSize(width: naturalSize.height, height: naturalSize.width)
        }
    }
}
