//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import AVKit
import UIKit.UIImage

@MainActor
final class FullscreenCellViewModel: ObservableObject {

    let mediaModel: MediaModelProtocol

    @Published var image: UIImage? = nil
    @Published var player: AVPlayer? = nil

    private var isPlaying = false
    private var currentTask: Task<Void, Never>?

    init(mediaModel: MediaModelProtocol) {
        self.mediaModel = mediaModel
    }

    func onStart() async {
        guard image == nil || player == nil else { return }

        currentTask?.cancel()
        currentTask = Task {
            switch self.mediaModel.mediaType {
            case .image:
                let data = try? await mediaModel.getData() // url is slow to load in UI, this way photos don't flocker when swiping
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            case .video:
                let url = await mediaModel.getURL()
                guard let url = url else { return }
                DispatchQueue.main.async {
                    self.player = AVPlayer(url: url)
                }
            case .none:
                break
            }
        }
    }

    func onStop() {
        currentTask = nil
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
}
