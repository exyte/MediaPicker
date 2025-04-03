//
//  Created by Alex.M on 06.06.2022.
//

import SwiftUI

struct LiveCameraCell: View {
    
    @Environment(\.scenePhase) private var scenePhase

    let action: () -> Void
    
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var orientation = UIDevice.current.orientation
    
    var body: some View {
        Button {
            action()
        } label: {
            LiveCameraView(
                session: cameraViewModel.captureSession,
                videoGravity: .resizeAspectFill,
                orientation: orientation
            )
            .overlay(
                Image(systemName: "camera")
                    .foregroundColor(.white)
            )
        }
        .onChange(of: scenePhase) {
            Task {
                if scenePhase == .background {
                    await cameraViewModel.stopSession()
                } else if scenePhase == .active {
                    await cameraViewModel.startSession()
                }
            }
        }
        .onRotate { orientation = $0 }
    }
}
