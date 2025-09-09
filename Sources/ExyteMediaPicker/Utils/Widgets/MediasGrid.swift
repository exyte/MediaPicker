//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

public struct MediasGrid<Element, Camera, Content, LoadingCell>: View
where Element: Identifiable, Camera: View, Content: View, LoadingCell: View {

    public let data: [Element]
    public let showingLiveCameraCell: Bool
    public let camera: () -> Camera
    public let content: (Element, _ index: Int, _ size: CGFloat) -> Content
    public let loadingCell: () -> LoadingCell

    @Environment(\.mediaPickerTheme) private var theme

    public init(
        _ data: [Element],
        showingLiveCameraCell: Bool,
        @ViewBuilder camera: @escaping () -> Camera,
        @ViewBuilder content: @escaping (Element, Int, CGFloat) -> Content,
        @ViewBuilder loadingCell: @escaping () -> LoadingCell
    ) {
        self.data = data
        self.showingLiveCameraCell = showingLiveCameraCell
        self.camera = camera
        self.content = content
        self.loadingCell = loadingCell
    }

    public var body: some View {
        let (columnWidth, columns) = calculateColumnWidth(
            spacing: theme.cellStyle.columnsSpacing
        )
        let spacing = theme.cellStyle.rowSpacing
        let columnCount = columns.count

        if showingLiveCameraCell {
            let indexedData = Array(data.enumerated())
            let itemsToTake = (columnCount - 1) * 2

            let topData = indexedData.prefix(itemsToTake)
            let remainingData = indexedData.dropFirst(itemsToTake)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: spacing) {
                    camera()
                        .frame(
                            width: columnWidth,
                            height: columnWidth * 2 + spacing
                        )
                        .clipped()

                    let topColumns = Array(
                        repeating: GridItem(
                            .fixed(columnWidth),
                            spacing: spacing,
                            alignment: .top
                        ),
                        count: columnCount - 1
                    )

                    LazyVGrid(columns: topColumns, spacing: spacing) {
                        ForEach(topData, id: \.element.id) { index, element in
                            content(element, index, columnWidth)
                        }
                    }
                }
                .padding(.bottom, spacing)

                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(remainingData, id: \.element.id) { index, element in
                        content(element, index, columnWidth)
                    }
                    loadingCell()
                }
            }
        } else {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, element in
                    content(element, index, columnWidth)
                }
                loadingCell()
            }
        }
    }
}
