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
    public let type: MediaType
    internal let source: Source
}

// MARK: - Public methods to get data from MediaItem
public extension Media {

    func getData() async -> Data? {
        switch source {
        case .media(let media):
            return await media.source.data()
        case .url(let url):
            return try? Data(contentsOf: url)
        }
    }

    func getUrl() async -> URL? {
        switch source {
        case .media(let media):
            return await media.source.getURL()
        case .url(let url):
            return url
        }
    }
}

// MARK: - Inner types
extension Media {
    enum Source {
        case media(AssetMediaModel)
        case url(URL)
    }
}
