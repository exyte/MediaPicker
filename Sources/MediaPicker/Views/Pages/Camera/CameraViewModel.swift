//
//  CameraViewModel.swift
//  
//
//  Created by Alexandra Afonasova on 18.10.2022.
//

import Foundation
import AVFoundation
import Combine
import UIKit
import SwiftUI

final class CameraViewModel: NSObject, ObservableObject {

    @Published private(set) var deviceOrientation = UIDevice.current.orientation
    @Published private(set) var flashEnabled = false
    @Published private(set) var snapOverlay = false

    let captureSession = AVCaptureSession()
    var capturedPhotoPublisher: AnyPublisher<URL, Never> { capturedPhotoSubject.eraseToAnyPublisher() }

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "LiveCameraQueue")
    private let capturedPhotoSubject = PassthroughSubject<URL, Never>()
    private var cameraPosition: AVCaptureDevice.Position = .back

    override init() {
        super.init()
        sessionQueue.async { [weak self] in
            self?.configureSession()
            self?.captureSession.startRunning()
        }
    }

    deinit {
        captureSession.stopRunning()
    }

    func startSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashEnabled ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)

        withAnimation(.linear(duration: 0.1)) { snapOverlay = true }
        withAnimation(.linear(duration: 0.1).delay(0.1)) { snapOverlay = false }
    }

    func flipCamera() {
        sessionQueue.async { [weak self] in
            guard let session = self?.captureSession, let input = session.inputs.first else {
                return
            }

            let newPosition: AVCaptureDevice.Position = self?.cameraPosition == .back ? .front : .back

            session.beginConfiguration()
            session.removeInput(input)
            self?.addInput(to: session, for: newPosition)
            session.commitConfiguration()
        }
    }

    func toggleFlash() {
        flashEnabled.toggle()
    }

    func orientationChanged(_ orientation: UIDeviceOrientation) {
        deviceOrientation = orientation
        sessionQueue.async { [weak self] in
            self?.updateOutputOrientation()
        }
    }

    private func configureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        addInput(to: captureSession)
        addOutput(to: captureSession)
        captureSession.commitConfiguration()
    }

    private func addInput(to session: AVCaptureSession, for position: AVCaptureDevice.Position = .back) {
        guard let captureDevice = selectCaptureDevice(for: position) else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard session.canAddInput(captureDeviceInput) else { return }
        session.addInput(captureDeviceInput)
        cameraPosition = position
    }

    private func addOutput(to session: AVCaptureSession) {
        photoOutput.isLivePhotoCaptureEnabled = false
        guard session.canAddOutput(photoOutput) else { return }
        session.addOutput(photoOutput)
        updateOutputOrientation()
    }

    private func updateOutputOrientation() {
        guard let connection = photoOutput.connection(with: .video), connection.isVideoOrientationSupported else { return }
        switch deviceOrientation {
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            connection.videoOrientation = .landscapeRight
        case .landscapeRight:
            connection.videoOrientation = .landscapeLeft
        default:
            connection.videoOrientation = .portrait
        }
    }

    private func selectCaptureDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInDualCamera,
                .builtInDualWideCamera,
                .builtInTripleCamera,
                .builtInTelephotoCamera,
                .builtInTrueDepthCamera,
                .builtInUltraWideCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: position)
        return session.devices.last
    }

}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let cgImage = photo.cgImageRepresentation() else { return }
        
        let photoOrientation: UIImage.Orientation
        if let rawOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
           let orientation = UIImage.Orientation.orientation(fromCGOrientationRaw: rawOrientation) {
            photoOrientation = orientation
        } else {
            photoOrientation = .up
        }
        guard let data = UIImage(
            cgImage: cgImage,
            scale: 1,
            orientation: photoOrientation
        ).jpegData(compressionQuality: 0.8) else { return }

        capturedPhotoSubject.send(FileManager.storeToTempDir(data: data))
    }
}
