//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import AVKit
import UIKit.UIImage

@MainActor
final class FullscreenCellViewModel: ObservableObject {
    
    let media: AssetMediaModel
    
    @Published var preview: UIImage? = nil
    @Published var player: AVPlayer? = nil
    @Published var isImageSet = false
    var imageCancellable: AnyCancellable?
    
    init(media: AssetMediaModel) {
        self.media = media
    }
    
    func onStart() async {
        guard preview == nil || player == nil else { return }
        switch media.mediaType {
        case .image:
            fetchImage()
        case .video:
            await fetchVideo()
        default:
            break
        }
    }
    
    func onStop() {
        imageCancellable = nil
        preview = nil
        player = nil
    }
    
    private func fetchImage() {
        let size = CGSize(width: media.source.pixelWidth, height: media.source.pixelHeight)
        imageCancellable = media.source
            .image(size: size)
            .sink { [weak self] in
                self?.preview = $0
                self?.isImageSet = true
            }
    }
    
    private func fetchVideo() async {
        let url = await media.source.getURL()
        guard let url = url else {
            return
        }
        player = AVPlayer(url: url)
    }
}
