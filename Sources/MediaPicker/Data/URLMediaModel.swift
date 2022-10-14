//
//  SwiftUIView.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct URLMediaModel {
    let url: URL
}

extension URLMediaModel {

    var mediaType: MediaType? {
//        switch source.mediaType {
//        case .image:
//            return .image
//        case .video:
//            return .video
//        default:
//            return nil
//        }
        return .image
    }
}

extension URLMediaModel: Identifiable {
    var id: String {
        url.absoluteString
    }
}

extension URLMediaModel: Equatable {
    static func ==(lhs: URLMediaModel, rhs: URLMediaModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension URL {
    var isImageFile: Bool {
        UTType(filenameExtension: pathExtension)?.conforms(to: .image) ?? false
    }
}
