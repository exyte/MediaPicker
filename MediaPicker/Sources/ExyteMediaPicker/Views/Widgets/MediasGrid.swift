//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

public struct MediasGrid<Element, Camera, Content, LoadingCell>: View
where Element: Identifiable, Camera: View, Content: View, LoadingCell: View {

    public let data: [Element]
    public let camera: () -> Camera
    public let content: (Element, _ index: Int, _ size: CGFloat) -> Content
    public let loadingCell: () -> LoadingCell

    @Environment(\.mediaPickerTheme) private var theme

    public init(_ data: [Element],
                @ViewBuilder camera: @escaping () -> Camera,
                @ViewBuilder content: @escaping (Element, Int, CGFloat) -> Content,
                @ViewBuilder loadingCell: @escaping () -> LoadingCell) {
        self.data = data
        self.camera = camera
        self.content = content
        self.loadingCell = loadingCell
    }

    public var body: some View {
        let (columnWidth, columns) = calculateColumnWidth(spacing: theme.cellStyle.columnsSpacing)
        LazyVGrid(columns: columns, spacing: theme.cellStyle.rowSpacing) {
            camera()
            ForEach(data.indices, id: \.self) { index in
                content(data[index], index, columnWidth)
            }
            loadingCell()
        }
    }
}
