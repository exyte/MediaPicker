//
//  Created by Alex.M on 31.05.2022.
//

import Foundation

public enum MediaType {
    case image
    case video
}

public struct Media: Identifiable, Equatable, Sendable {
    public var id = UUID()
    public let source: MediaModelProtocol

    public init(source: MediaModelProtocol) {
        self.source = source
    }

    public static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.id == rhs.id
    }
}

public extension Media {

    var type: MediaType {
        source.mediaType ?? .image
    }

    var duration: CGFloat? {
        get async {
            await source.duration
        }
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
