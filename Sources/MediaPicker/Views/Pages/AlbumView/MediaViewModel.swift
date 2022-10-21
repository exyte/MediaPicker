//
//  Created by Alex.M on 03.06.2022.
//

import Combine
#if os(iOS)
import UIKit.UIImage
#endif

class MediaViewModel: ObservableObject {
    let media: AssetMediaModel
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(media: AssetMediaModel) {
        self.media = media
    }
    
#if os(iOS)
    @Published var preview: UIImage? = nil
#else
    // FIXME: Create preview for image/video for other platforms
#endif
    
    func onStart(size: CGSize) {
        media.source
            .image(size: size)
            .sink {
                self.preview = $0
            }
            .store(in: &subscriptions)
    }
    
    func onStop() {
        subscriptions.cancelAll()
    }
}
