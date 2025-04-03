//
//  Created by Alex.M on 31.05.2022.
//

import SwiftUI
import Photos

struct CustomCameraView<CameraViewContent: View>: View {

    @EnvironmentObject private var cameraSelectionService: CameraSelectionService

    public typealias CameraViewClosure = ((LiveCameraView, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure, @escaping SimpleClosure) -> CameraViewContent)

    // params
    @ObservedObject var viewModel: MediaPickerViewModel
    let didTakePicture: () -> Void
    let didPressCancel: () -> Void
    var cameraViewBuilder: CameraViewClosure

    @StateObject private var cameraViewModel = CameraViewModel()

    var body: some View {
        cameraViewBuilder(
            LiveCameraView(
                session: cameraViewModel.captureSession,
                videoGravity: .resizeAspectFill,
                orientation: .portrait
            ),
            { // cancel
                if cameraSelectionService.hasSelected {
                    viewModel.showingExitCameraConfirmation = true
                } else {
                    didPressCancel()
                }
            },
            { viewModel.setPickerMode(.cameraSelection) }, // show preview of taken photos
            { Task { await cameraViewModel.takePhoto() } }, // takePhoto
            { Task { await cameraViewModel.startVideoCapture() } }, // start record video
            { Task { await cameraViewModel.stopVideoCapture() } }, // stop record video
            { Task { await cameraViewModel.toggleFlash() } }, // flash off/on
            { Task { await cameraViewModel.flipCamera() } } // camera back/front
        )
        .onChange(of: cameraViewModel.capturedPhoto) { _ , newValue in
            viewModel.pickedMediaUrl = newValue
            didTakePicture()
        }
    }
}

struct StandardConrolsCameraView: View {

    @EnvironmentObject private var cameraSelectionService: CameraSelectionService
    @Environment(\.mediaPickerTheme) private var theme
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject var viewModel: MediaPickerViewModel
    let didTakePicture: () -> Void
    let didPressCancel: () -> Void
    let selectionParamsHolder: SelectionParamsHolder

    @StateObject private var cameraViewModel = CameraViewModel()

    @State private var capturingPhotos = true
    @State private var videoCaptureInProgress = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    if cameraSelectionService.hasSelected {
                        viewModel.showingExitCameraConfirmation = true
                    } else {
                        didPressCancel()
                    }
                }
                .foregroundColor(theme.main.cameraText)
                .padding(12, 18)

                Spacer()
            }
            .safeAreaPadding(.top, UIApplication.safeArea.top)

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
            .applyIf(cameraViewModel.zoomAllowed) {
                $0.gesture(
                    MagnificationGesture()
                        .onChanged(cameraViewModel.zoomChanged(_:))
                        .onEnded(cameraViewModel.zoomEnded(_:))
                )
            }

            VStack(spacing: 10) {
                if cameraSelectionService.hasSelected {
                    HStack {
                        Button("Done") {
                            if cameraSelectionService.hasSelected {
                                viewModel.setPickerMode(.cameraSelection)
                            }
                        }
                        Spacer()
                        if selectionParamsHolder.mediaType.allowsVideo {
                            photoVideoToggle
                        }
                        Spacer()
                        Text("\(cameraSelectionService.selected.count)")
                            .font(.system(size: 15))
                            .foregroundStyle(theme.main.cameraText)
                            .padding(8)
                            .overlay(Circle()
                                .stroke(theme.main.cameraText, lineWidth: 2))
                    }
                    .foregroundColor(theme.main.cameraText)
                    .padding(.horizontal, 12)
                }
                else if selectionParamsHolder.mediaType.allowsVideo {
                    photoVideoToggle
                        .padding(.bottom, 8)
                }

                HStack(spacing: 40) {
                    AsyncButton {
                        await cameraViewModel.toggleFlash()
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

                    AsyncButton {
                        await cameraViewModel.flipCamera()
                    } label: {
                        Image("FlipCamera", bundle: .current)
                    }
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 50)
        }
        .background(theme.main.cameraBackground)
        .onChange(of: scenePhase) {
            Task {
                if scenePhase == .background {
                    await cameraViewModel.stopSession()
                } else if scenePhase == .active {
                    await cameraViewModel.startSession()
                }
            }
        }
        .onChange(of: cameraViewModel.capturedPhoto) { _ , newValue in
            if let photo = newValue {
                viewModel.pickedMediaUrl = photo
                didTakePicture()
            }
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
                Task {
                    await cameraViewModel.takePhoto()
                }
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

            AsyncButton {
                await cameraViewModel.startVideoCapture()
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

            AsyncButton {
                await cameraViewModel.stopVideoCapture()
                videoCaptureInProgress = false
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
            }
        }
    }
}
