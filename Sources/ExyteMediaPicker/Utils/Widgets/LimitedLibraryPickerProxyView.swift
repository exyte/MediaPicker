//
//  Created by Alex.M on 02.06.2022.
//

import SwiftUI
import UIKit
import PhotosUI

@MainActor
struct LimitedLibraryPickerProxyView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var didDismiss: @Sendable ()->()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        DispatchQueue.main.async { [controller] in
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
            trackCompletion(in: controller)
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func trackCompletion(in controller: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak controller] in
            if controller?.presentedViewController == nil {
                self.$isPresented.wrappedValue = false
                self.didDismiss()
            } else if let controller = controller {
                self.trackCompletion(in: controller)
            }
        }
    }
}
