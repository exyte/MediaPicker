//
//  Created by Alex.M on 03.06.2022.
//

#if os(iOS)
import UIKit.UIImage
#endif

class AlbumCellViewModel: ObservableObject {
    let album: AlbumModel
    
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
        
        album.preview?.source
            .image(size: size)
            .assign(to: &$preview)
    }
}
