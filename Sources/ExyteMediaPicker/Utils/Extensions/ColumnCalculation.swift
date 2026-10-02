//
//  Untitled.swift
//  ExyteMediaPicker
//
//  Created by Alisa Mylnikova on 25.03.2025.
//

import SwiftUI

@MainActor
func calculateColumnWidth(availableWidth: CGFloat, spacing: CGFloat) -> (CGFloat, [GridItem]) {
    let wholeCount = 3.0
    let noSpaces = max(availableWidth - spacing * (wholeCount - 1), 0)
    let columnWidth = noSpaces / wholeCount
    let columns = Array(repeating: GridItem(.fixed(columnWidth), spacing: spacing, alignment: .top), count: Int(wholeCount))
    return (columnWidth, columns)
}
