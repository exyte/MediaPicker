//
//  FileManager.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI

extension FileManager {

    static var tempPath: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    static func storeToTempDir(url: URL) -> URL {
        let id = UUID().uuidString
        let path = FileManager.tempPath.appendingPathComponent(id)

        try? FileManager.default.copyItem(at: url, to: path)
        return path
    }

    static func storeToTempDir(data: Data) -> URL {
        let id = UUID().uuidString
        let path = FileManager.tempPath.appendingPathComponent(id)

        try? data.write(to: path)
        return path
    }
}
