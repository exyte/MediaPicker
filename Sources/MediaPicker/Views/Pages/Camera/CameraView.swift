//
//  Created by Alex.M on 31.05.2022.
//

import SwiftUI
import Photos

struct CameraView: UIViewControllerRepresentable {

    @ObservedObject var viewModel: MediaPickerViewModel

    var didTakePicture: ()->()
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? ["public.image", "public.movie"]
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator

        let hostingController = UIHostingController(rootView: CameraOverlayView(viewModel: viewModel) {
            viewModel.showingCamera = false
        } onFlash: {
            imagePicker.cameraFlashMode = (imagePicker.cameraFlashMode == .on ? .off : .on)
        } onFlip: {
            imagePicker.cameraDevice = (imagePicker.cameraDevice == .front ? .rear : .front)
        } onTake: {
            imagePicker.takePicture()
        })

        hostingController._disableSafeArea = true
        hostingController.view?.frame = CGRect(x: UIScreen.main.bounds.minX, y: UIScreen.main.bounds.minY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        hostingController.view?.backgroundColor = .clear

        imagePicker.showsCameraControls = false
        imagePicker.cameraOverlayView = hostingController.view
        imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: 2, y: 2)
        return imagePicker
    }
    
    func makeCoordinator() -> CameraCoordinatorProtocol {
        CameraCoordinator(pickedMediaUrl: $viewModel.pickedMediaUrl, isPresented: $viewModel.showingCamera, didTakePicture: didTakePicture)
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        /* Do nothing */
    }
}

protocol CameraCoordinatorProtocol: UINavigationControllerDelegate, UIImagePickerControllerDelegate {}

private class CameraCoordinator: NSObject, CameraCoordinatorProtocol {

    @Binding var pickedMediaUrl: URL?
    @Binding var isPresented: Bool

    var didTakePicture: ()->()

    init(pickedMediaUrl: Binding<URL?>, isPresented: Binding<Bool>, didTakePicture: @escaping ()->()) {
        _pickedMediaUrl = pickedMediaUrl
        _isPresented = isPresented
        self.didTakePicture = didTakePicture
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let type = info[UIImagePickerController.InfoKey.mediaType] as? String else { return } // TODO: Create error

        switch type {
        case "public.movie":
            if let sourceUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                pickedMediaUrl = FileManager.storeToTempDir(url: sourceUrl)
                didTakePicture()
            }
        case "public.image":
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                if let data = image.jpegData(compressionQuality: 0.8) {
                    pickedMediaUrl = FileManager.storeToTempDir(data: data)
                    didTakePicture()
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
