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

    struct CaptureDevice {
        let device: AVCaptureDevice
        let position: AVCaptureDevice.Position
        let defaultZoom: CGFloat
        let maxZoom: CGFloat
    }

    @Published private(set) var deviceOrientation = UIDevice.current.orientation
    @Published private(set) var flashEnabled = false
    @Published private(set) var snapOverlay = false

    let captureSession = AVCaptureSession()
    var capturedPhotoPublisher: AnyPublisher<URL, Never> { capturedPhotoSubject.eraseToAnyPublisher() }

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "LiveCameraQueue")
    private let capturedPhotoSubject = PassthroughSubject<URL, Never>()
    private var captureDevice: CaptureDevice?

    private let minScale: CGFloat = 1
    private let singleCameraMaxScale: CGFloat = 5
    private let dualCameraMaxScale: CGFloat = 8
    private let tripleCameraMaxScale: CGFloat = 12
    private var lastScale: CGFloat = 1
    private var zoomAllowed: Bool { captureDevice?.position == .back }

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

            let newPosition: AVCaptureDevice.Position = self?.captureDevice?.position == .back ? .front : .back

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

    func zoomChanged(_ scale: CGFloat) {
        if !zoomAllowed { return }
        zoomCamera(resolveScale(scale))
    }

    func zoomEnded(_ scale: CGFloat) {
        if !zoomAllowed { return }

        lastScale = resolveScale(scale)
        zoomCamera(lastScale)
    }

    private func resolveScale(_ gestureScale: CGFloat) -> CGFloat {
        let newScale = lastScale * gestureScale
        let maxScale = captureDevice?.maxZoom ?? singleCameraMaxScale
        return max(min(maxScale, newScale), minScale)
    }

    private func zoomCamera(_ scale: CGFloat) {
        do {
            try captureDevice?.device.lockForConfiguration()
            captureDevice?.device.videoZoomFactor = scale
            captureDevice?.device.unlockForConfiguration()
        } catch {}
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

        let defaultZoom = CGFloat(truncating: captureDevice.virtualDeviceSwitchOverVideoZoomFactors.first ?? minScale as NSNumber)

        let maxZoom: CGFloat
        let cameraCount = captureDevice.virtualDeviceSwitchOverVideoZoomFactors.count + 1
        switch cameraCount {
        case 1: maxZoom = singleCameraMaxScale
        case 2: maxZoom = dualCameraMaxScale
        default: maxZoom = tripleCameraMaxScale
        }

        let device = CaptureDevice(
            device: captureDevice,
            position: position,
            defaultZoom: defaultZoom,
            maxZoom: maxZoom
        )
        self.captureDevice = device

        if position == .back {
            captureDeviceInput.device.videoZoomFactor = device.defaultZoom
            lastScale = device.defaultZoom
        }
    }

    private func addOutput(to session: AVCaptureSession) {
        photoOutput.isLivePhotoCaptureEnabled = false
        guard session.canAddOutput(photoOutput) else { return }
        session.addOutput(photoOutput)
        updateOutputOrientation()
    }

    private func updateOutputOrientation() {
        guard let connection = photoOutput.connection(with: .video), connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = AVCaptureVideoOrientation(deviceOrientation)
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

        if let camera = session.devices.first(where: { $0.deviceType == .builtInTripleCamera }) {
            return camera
        } else if let camera = session.devices.first(where: { $0.deviceType == .builtInDualCamera }) {
            return camera
        } else {
            return session.devices.first
        }
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
