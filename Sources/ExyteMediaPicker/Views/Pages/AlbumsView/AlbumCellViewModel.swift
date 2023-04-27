//
//  Created by Alex.M on 03.06.2022.
//

#if os(iOS)
import UIKit.UIImage
#endif
import Combine

class AlbumCellViewModel: ObservableObject {
    let album: AlbumModel
    private var previewCancellable: AnyCancellable?
    
    init(album: AlbumModel) {
        self.album = album
    }
    
#if os(iOS)
    @Published var preview: UIImage? = nil
#else
    // FIXME: Create preview for image/video for other platforms
#endif
    
    func fetchPreview(size: CGSize) {
        guard preview == nil else { return }
        
        previewCancellable = album.preview?.asset
            .image(size: size)
            .sink(receiveValue: { [weak self] in
                self?.preview = $0
            })
    }
}
