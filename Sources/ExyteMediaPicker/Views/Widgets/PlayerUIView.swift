//
//  File.swift
//  
//
//  Created by Alisa Mylnikova on 04.09.2023.
//

import SwiftUI
import AVFoundation

struct PlayerView: UIViewRepresentable {

    var player: AVPlayer
    var bgColor: Color

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(player: player, bgColor: bgColor)
    }

    func updateUIView(_ uiView: PlayerUIView, context: UIViewRepresentableContext<PlayerView>) {
        uiView.playerLayer.player = player
    }
}

class PlayerUIView: UIView {

    // MARK: Class Property

    let playerLayer = AVPlayerLayer()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(player: AVPlayer, bgColor: Color) {
        super.init(frame: .zero)
        self.playerSetup(player: player, bgColor: bgColor)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Life-Cycle

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    // MARK: Class Methods

    private func playerSetup(player: AVPlayer, bgColor: Color) {
        playerLayer.player = player
        player.actionAtItemEnd = .none
        layer.addSublayer(playerLayer)
        print(bgColor.description.debugDescription)
        playerLayer.backgroundColor = bgColor.cgColor
    }
}
