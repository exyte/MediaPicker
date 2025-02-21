//
//  Created by Alex.M on 31.05.2022.
//

import SwiftUI

struct ThumbnailView: View {

#if os(iOS)
    let preview: UIImage?
    let size: CGFloat
#else
    // FIXME: Create preview for image/video for other platforms
#endif
    
    var body: some View {
        if let preview = preview {
            Image(uiImage: preview)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipped()
        } else {
            ThumbnailPlaceholder()
        }
    }
}
