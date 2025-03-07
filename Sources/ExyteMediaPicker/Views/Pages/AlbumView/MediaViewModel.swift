//
//  Created by Alex.M on 03.06.2022.
//

#if os(iOS)
import UIKit.UIImage
#endif
import Photos

class MediaViewModel: ObservableObject {
    let assetMediaModel: AssetMediaModel
    
    private var requestID: PHImageRequestID?
    
    init(assetMediaModel: AssetMediaModel) {
        self.assetMediaModel = assetMediaModel
    }
    
#if os(iOS)
    @Published var preview: UIImage? = nil
#else
    // FIXME: Create preview for image/video for other platforms
#endif
    
    @MainActor func onStart(size: CGFloat) {
        requestID = assetMediaModel.asset
            .image(size: CGSize(width: size, height: size)) { image in
                DispatchQueue.main.async {
                    self.preview = image
                }
            }
    }
    
    func onStop() {
        if let requestID = requestID {
            PHCachingImageManager.default().cancelImageRequest(requestID)
        }
    }
}
