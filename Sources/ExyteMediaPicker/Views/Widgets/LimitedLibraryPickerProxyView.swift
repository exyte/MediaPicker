//
//  Created by Alex.M on 02.06.2022.
//

import SwiftUI
import UIKit
import PhotosUI

struct LimitedLibraryPickerProxyView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var didDismiss: @Sendable ()->()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        DispatchQueue.main.async { [controller] in
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
            context.coordinator.trackCompletion(in: controller)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, didDismiss: didDismiss)
    }
    
    final class Coordinator: NSObject, Sendable {
        private let isPresented: Binding<Bool>
        let didDismiss: @Sendable ()->()

        init(isPresented: Binding<Bool>, didDismiss: @escaping @Sendable ()->()) {
            self.isPresented = isPresented
            self.didDismiss = didDismiss
        }
        
        func trackCompletion(in controller: UIViewController) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak controller] in
                if controller?.presentedViewController == nil {
                    self?.isPresented.wrappedValue = false
                    self?.didDismiss()
                } else if let controller = controller {
                    self?.trackCompletion(in: controller)
                }
            }
        }
    }
}
