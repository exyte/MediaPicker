//
//  File.swift
//  ExyteMediaPicker
//
//  Created by Alisa Mylnikova on 25.02.2025.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
