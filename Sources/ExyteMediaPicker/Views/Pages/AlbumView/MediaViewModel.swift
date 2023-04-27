//
//  Created by Alex.M on 03.06.2022.
//

import Combine
#if os(iOS)
import UIKit.UIImage
#endif

class MediaViewModel: ObservableObject {
    let assetMediaModel: AssetMediaModel
    
    private var imageCancellable: AnyCancellable?
    
    init(assetMediaModel: AssetMediaModel) {
        self.assetMediaModel = assetMediaModel
    }
    
#if os(iOS)
    @Published var preview: UIImage? = nil
#else
    // FIXME: Create preview for image/video for other platforms
#endif
    
    func onStart(size: CGSize) {
        imageCancellable = assetMediaModel.asset
            .image(size: size)
            .sink {
                self.preview = $0
            }
    }
    
    func onStop() {
        imageCancellable = nil
    }
}
