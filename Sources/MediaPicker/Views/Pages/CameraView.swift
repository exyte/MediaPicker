//
//  Created by Alex.M on 31.05.2022.
//

import SwiftUI
import Photos

struct CameraView: UIViewControllerRepresentable {
    @Binding var pickedAssetId: String?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? ["public.image", "public.movie"]
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func makeCoordinator() -> CameraCoordinatorProtocol {
        CameraCoordinator(pickedAssetId: $pickedAssetId, isPresented: $isPresented)
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        /* Do nothing */
    }
}

protocol CameraCoordinatorProtocol: UINavigationControllerDelegate, UIImagePickerControllerDelegate {}

private class CameraCoordinator: NSObject, CameraCoordinatorProtocol {
    @Binding var pickedAssetId: String?
    @Binding var isPresented: Bool

    init(pickedAssetId: Binding<String?>, isPresented: Binding<Bool>) {
        _pickedAssetId = pickedAssetId
        _isPresented = isPresented
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        defer {
            isPresented = false
        }

        guard let type = info[UIImagePickerController.InfoKey.mediaType] as? String
        else { return } // TODO: Create error

        switch type {
        case "public.movie":
            if let sourceUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                do {
                    try PHPhotoLibrary.shared().performChangesAndWait { [weak self] in
                        let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: sourceUrl)
                        self?.pickedAssetId = request?.placeholderForCreatedAsset?.localIdentifier
                    }
                } catch {
                    print(error)
                }
            }
        case "public.image":
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                do {
                    try PHPhotoLibrary.shared().performChangesAndWait { [weak self] in
                        let request = PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
                        self?.pickedAssetId = request.placeholderForCreatedAsset?.localIdentifier
                    }
                } catch {
                    print(error)
                }
            }
        default:
            fatalError("Unknown media type")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isPresented = false
    }
}
