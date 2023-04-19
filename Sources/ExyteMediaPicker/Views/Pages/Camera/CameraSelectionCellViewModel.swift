//
//  CameraSelectionCellViewModel.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI
import AVKit

final class CameraSelectionCellViewModel: ObservableObject {

    let media: URLMediaModel

    @Published var preview: UIImage? = nil
    @Published var player: AVPlayer? = nil

    init(media: URLMediaModel) {
        self.media = media
    }

    func onStart() {
        switch media.mediaType {
        case .image:
            fetchImage()
        case .video:
            fetchVideo()
        default:
            break
        }
    }

    func onStop() {}

    private func fetchImage() {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: self.media.url)
                DispatchQueue.main.async { [weak self] in
                    self?.preview = UIImage(data: data)
                }
            } catch {

            }
        }
    }

    private func fetchVideo() {
        player = AVPlayer(url: media.url)
    }
}
