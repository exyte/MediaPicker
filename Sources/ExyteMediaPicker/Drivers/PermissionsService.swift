//
//  Created by Alex.M on 08.06.2022.
//

import Foundation
import Combine
import AVFoundation
import Photos

@MainActor
final class PermissionsService: ObservableObject {

    static var shared = PermissionsService()

    @Published var cameraPermissionStatus: CameraPermissionStatus = .unknown
    @Published var photoLibraryPermissionStatus: PhotoLibraryPermissionStatus = .unknown

    /// photoLibraryChangePermissionPublisher gets called multiple times even when nothing changed in photo library, so just use this one to make sure the closure runs exactly once
    func requestPhotoLibraryPermission(_ permissionGrantedClosure: @Sendable @escaping ()->()) {
        Task {
            let currentStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            if currentStatus == .authorized || currentStatus == .limited {
                permissionGrantedClosure()
                return
            }

            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            updatePhotoLibraryAuthorizationStatus()
            if status == .authorized || status == .limited {
                permissionGrantedClosure()
            }
        }
    }

    func requestCameraPermission() {
        Task {
            await AVCaptureDevice.requestAccess(for: .video)
            updateCameraAuthorizationStatus()
        }
    }

    func updatePhotoLibraryAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        let result: PhotoLibraryPermissionStatus
        switch status {
        case .authorized:
            result = .authorized
        case .limited:
            result = .limited
        case .restricted, .denied:
            result = .unavailable
        case .notDetermined:
            result = .unknown
        default:
            result = .unknown
        }

        DispatchQueue.main.async { [weak self] in
            self?.photoLibraryPermissionStatus = result
        }
    }

    func updateCameraAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        let result: CameraPermissionStatus
#if targetEnvironment(simulator)
        result = .unavailable
#else
        switch status {
        case .authorized:
            result = .authorized
        case .restricted, .denied:
            result = .unavailable
        case .notDetermined:
            result = .unknown
        default:
            result = .unknown
        }
#endif
        DispatchQueue.main.async { [weak self] in
            self?.cameraPermissionStatus = result
        }
    }
}

extension PermissionsService {
    enum CameraPermissionStatus {
        case authorized
        case unavailable
        case unknown
    }

    enum PhotoLibraryPermissionStatus {
        case limited
        case authorized
        case unavailable
        case unknown
    }
}
