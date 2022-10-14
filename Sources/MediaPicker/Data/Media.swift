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

    func getData() -> Future<Data?, Never> {
        Future { promise in
            switch source {
            case .media(let media):
                Task {
                    let data = await media.source.data()
                    promise(.success(data))
                }
            case .url(let url):
                DispatchQueue.global().async {
                    do {
                        let data = try Data(contentsOf: url)
                        promise(.success(data))
                    } catch {
                        promise(.success(nil))
                    }
                }
            }
        }
    }

    func getUrl() -> Future<URL?, Never> {
        Future { promise in
            switch source {
            case .media(let media):
                media.source.getURL { url in
                    promise(.success(url))
                }
            case .url(let url):
                promise(.success(url))
            }
        }
    }
}

// MARK: - Media+Identifiable
//extension Media: Identifiable {
//    public var id: String {
//        switch source {
//        case .media(let media):
//            return media.id
//        case .url(let url):
//            return url.absoluteString
//        }
//    }
//}
//
//extension Media: Equatable {
//    public static func == (lhs: Media, rhs: Media) -> Bool {
//        lhs.id == rhs.id
//    }
//}

// MARK: - Inner types
extension Media {
    enum Source {
        case media(MediaModel)
        case url(URL)
    }
}
