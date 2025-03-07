//
//  Created by Alex.M on 08.06.2022.
//

import Foundation
import Combine
import Photos

let photoLibraryChangePermissionNotification = Notification.Name(rawValue: "PhotoLibraryChangePermissionNotification")

let photoLibraryChangeLimitedPhotosNotification = Notification.Name(rawValue: "PhotoLibraryChangeLimitedPhotosNotification")

let cameraChangePermissionNotification = Notification.Name(rawValue: "cameraChangePermissionNotification")

final class PhotoLibraryChangePermissionWatcher: NSObject, PHPhotoLibraryChangeObserver {
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // gets called too often, even if nothing changed - a bug?
        NotificationCenter.default.post(
            name: photoLibraryChangePermissionNotification,
            object: nil)
    }
}
