//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

public struct MediasGrid<Data, Camera, Content, LoadingCell>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Camera: View, Content: View, LoadingCell: View {

    public let data: Data
    public let camera: () -> Camera
    public let content: (Data.Element, _ size: CGFloat) -> Content
    public let loadingCell: () -> LoadingCell
    
    @Environment(\.mediaPickerTheme) private var theme

    let minColumnWidth: CGFloat = 100
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: minColumnWidth), spacing: theme.cellStyle.columnsSpacing, alignment: .top)]
    }

    public init(_ data: Data, @ViewBuilder camera: @escaping () -> Camera, @ViewBuilder content: @escaping (Data.Element, CGFloat) -> Content, @ViewBuilder loadingCell: @escaping () -> LoadingCell) {
        self.data = data
        self.camera = camera
        self.content = content
        self.loadingCell = loadingCell
    }

    public var body: some View {
        GeometryReader { g in
            let columnWidth = calculateColumnWidth(g.size.width)
            LazyVGrid(columns: columns, spacing: theme.cellStyle.rowSpacing) {
                camera()
                ForEach(data) { item in
                    content(item, columnWidth)
                }
                loadingCell()
            }
        }
    }

    func calculateColumnWidth(_ gridWidth: CGFloat) -> CGFloat {
        let wholeCount = CGFloat(Int(gridWidth / minColumnWidth))
        let noSpaces = gridWidth - theme.cellStyle.columnsSpacing * (wholeCount - 1)
        return noSpaces / wholeCount
    }
}
