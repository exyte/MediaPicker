//
//  SwiftUIView.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI

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

