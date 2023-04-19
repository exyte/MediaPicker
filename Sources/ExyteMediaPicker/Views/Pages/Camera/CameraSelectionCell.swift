//
//  CameraSelectionCell.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI
import AVKit

struct CameraSelectionCell: View {

    @StateObject var viewModel: CameraSelectionCellViewModel

    var body: some View {
        VStack {
            if let preview = viewModel.preview {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
            } else if let player = viewModel.player {
                VideoPlayer(player: player)
                    .padding()
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .onAppear {
            viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}
