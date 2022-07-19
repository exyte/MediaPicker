//
//  FileManager.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI

extension FileManager {

    static var documentsPath: URL! {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    static func storeToFile(url: URL) -> URL {
        let id = UUID().uuidString
        let path = FileManager.documentsPath.appendingPathComponent(id)

        try? FileManager.default.copyItem(at: url, to: path)
        return path
    }

    static func storeToFile(data: Data) -> URL {
        let id = UUID().uuidString
        let path = FileManager.documentsPath.appendingPathComponent(id)

        try? data.write(to: path)
        return path
    }
}
