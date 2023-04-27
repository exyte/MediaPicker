//
//  Created by Alex.M on 31.05.2022.
//

import Foundation
import Combine

public enum MediaType {
    case image
    case video
}

public struct Media: Identifiable {
    public var id = UUID()
    internal let source: MediaModelProtocol
}

public extension Media {

    var type: MediaType {
        source.mediaType ?? .image
    }

    func getURL() async -> URL? {
        await source.getURL()
    }

    func getThumbnailURL() async -> URL? {
        await source.getThumbnailURL()
    }

    func getData() async -> Data? {
        try? await source.getData()
    }

    func getThumbnailData() async -> Data? {
        await source.getThumbnailData()
    }
}
