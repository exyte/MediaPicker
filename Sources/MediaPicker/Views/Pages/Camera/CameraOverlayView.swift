//
//  CameraOverlayView.swift
//
//  Created by Alisa Mylnikova on 15.07.2022.
//

import SwiftUI

struct CameraOverlayView: View {

    @ObservedObject var viewModel: MediaPickerViewModel

    var onCancel: ()->()
    var onFlash: ()->()
    var onFlip: ()->()
    var onTake: ()->()

    @EnvironmentObject private var cameraSelectionService: CameraSelectionService
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    if cameraSelectionService.hasSelected {
                        viewModel.showingExitCameraConfirmation = true
                    } else {
                        viewModel.showingCamera = false
                    }
                }
                .foregroundColor(.white)
                .padding(.top, safeAreaInsets.top)
                .padding(.leading)
                .padding(.bottom)
                Spacer()
            }
            .background(Color.black)

            Spacer()

            VStack(spacing: 0) {
                if cameraSelectionService.hasSelected {
                    HStack {
                        Button("Done") {
                            if cameraSelectionService.hasSelected {
                                viewModel.showingCameraSelection = true
                            }
                            viewModel.showingCamera = false
                        }
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

                HStack(spacing: 40) {
                    Button {
                        onFlash()
                    } label: {
                        Image("Flash")
                    }

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 6)
                            .frame(width: 72, height: 72)

                        Button {
                            onTake()
                        } label: {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                        }
                    }

                    Button {
                        onFlip()
                    } label: {
                        Image("FlipCamera")
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, safeAreaInsets.bottom)
            .frame(maxWidth: .infinity)
            .background(Color.black)
        }
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

private extension UIEdgeInsets {

    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
