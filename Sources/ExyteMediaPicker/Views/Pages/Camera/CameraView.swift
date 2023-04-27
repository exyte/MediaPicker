//
//  Created by Alex.M on 31.05.2022.
//

import SwiftUI
import Photos

struct CameraView: View {

    @ObservedObject var viewModel: MediaPickerViewModel
    let didTakePicture: () -> Void

    @StateObject private var cameraViewModel = CameraViewModel()
    @EnvironmentObject private var cameraSelectionService: CameraSelectionService
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.mediaPickerTheme) private var theme

    @State var capturingPhotos = true
    @State var videoCaptureInProgress = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    if cameraSelectionService.hasSelected {
                        viewModel.showingExitCameraConfirmation = true
                    } else {
                        viewModel.setPickerMode(.photos)
                    }
                }
                .foregroundColor(.white)
                .padding(.top, safeAreaInsets.top)
                .padding(.leading)
                .padding(.bottom)

                Spacer()
            }

            LiveCameraView(
                session: cameraViewModel.captureSession,
                videoGravity: .resizeAspectFill,
                orientation: .portrait
            )
            .overlay {
                if cameraViewModel.snapOverlay {
                    Rectangle()
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged(cameraViewModel.zoomChanged(_:))
                    .onEnded(cameraViewModel.zoomEnded(_:))
            )

            VStack(spacing: 10) {
                if cameraSelectionService.hasSelected {
                    HStack {
                        Button("Done") {
                            if cameraSelectionService.hasSelected {
                                viewModel.setPickerMode(.cameraSelection)
                            }
                        }
                        Spacer()
                        photoVideoToggle
                        Spacer()
                        Text("\(cameraSelectionService.selected.count)")
                            .font(.system(size: 15))
                            .padding(8)
                            .overlay(Circle()
                                .stroke(Color.white, lineWidth: 2))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                }
                else {
                    photoVideoToggle
                }

                HStack(spacing: 40) {
                    Button {
                        cameraViewModel.toggleFlash()
                    } label: {
                        Image(cameraViewModel.flashEnabled ? "FlashOn" : "FlashOff", bundle: .current)
                    }

                    if capturingPhotos {
                        takePhotoButton
                    } else if !videoCaptureInProgress {
                        startVideoCaptureButton
                    } else {
                        stopVideoCaptureButton
                    }

                    Button {
                        cameraViewModel.flipCamera()
                    } label: {
                        Image("FlipCamera", bundle: .current)
                    }
                }
            }
            .padding(.top, 24)
            .padding(.bottom, safeAreaInsets.bottom + 50)
        }
        .background(theme.main.cameraBackground)
        .onEnteredBackground(perform: cameraViewModel.stopSession)
        .onEnteredForeground(perform: cameraViewModel.startSession)
        .onReceive(cameraViewModel.capturedPhotoPublisher) {
            viewModel.pickedMediaUrl = $0
            didTakePicture()
        }
    }

    var photoVideoToggle: some View {
        HStack {
            Button("Video") {
                capturingPhotos = false
            }
            .foregroundColor(capturingPhotos ? Color.white : Color.yellow)

            Button("Photo") {
                capturingPhotos = true
            }
            .foregroundColor(capturingPhotos ? Color.yellow : Color.white)
        }
    }

    var takePhotoButton: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 6)
                .frame(width: 72, height: 72)

            Button {
                cameraViewModel.takePhoto()
            } label: {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
            }
        }
    }

    var startVideoCaptureButton: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 6)
                .frame(width: 72, height: 72)

            Button {
                cameraViewModel.startVideoCapture()
                videoCaptureInProgress = true
            } label: {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 60, height: 60)
            }
        }
    }

    var stopVideoCaptureButton: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 6)
                .frame(width: 72, height: 72)

            Button {
                cameraViewModel.stopVideoCapture()
                videoCaptureInProgress = false
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
            }
        }
    }
}
