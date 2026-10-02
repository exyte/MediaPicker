//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

public struct MediasGrid<Element, Camera, Content, LoadingCell>: View
where Element: Identifiable, Camera: View, Content: View, LoadingCell: View {

    public let data: [Element]
    public let liveCameraCellStyle: LiveCameraCellStyle
    public let availableWidth: CGFloat
    public let camera: () -> Camera
    public let content: (Element, _ index: Int, _ size: CGFloat) -> Content
    public let loadingCell: () -> LoadingCell

    @Environment(\.mediaPickerTheme) private var theme

    public init(_ data: [Element],
                liveCameraCell: LiveCameraCellStyle,
                availableWidth: CGFloat,
                @ViewBuilder camera: @escaping () -> Camera,
                @ViewBuilder content: @escaping (Element, Int, CGFloat) -> Content,
                @ViewBuilder loadingCell: @escaping () -> LoadingCell) {
        self.data = data
        self.liveCameraCellStyle = liveCameraCell
        self.availableWidth = availableWidth
        self.camera = camera
        self.content = content
        self.loadingCell = loadingCell
    }

    public var body: some View {
        let (columnWidth, columns) = calculateColumnWidth(
            availableWidth: availableWidth,
            spacing: theme.cellStyle.columnsSpacing
        )
        let spacing = theme.cellStyle.rowSpacing

        Group {
            if columnWidth <= 0 {
                // availableWidth hasn't been measured yet - bail out instead of laying out zero-height rows
                EmptyView()
            } else {
                mediasGrid(columnWidth: columnWidth, columns: columns, spacing: spacing)
            }
        }
        .frame(width: availableWidth, alignment: .leading)
    }

    @ViewBuilder
    private func mediasGrid(columnWidth: CGFloat, columns: [GridItem], spacing: CGFloat) -> some View {
        switch liveCameraCellStyle {
        case .prominant:
            let columnCount = columns.count
            let indexedData = Array(data.enumerated())
            let itemsToTake = (columnCount - 1) * 2
            let topData = indexedData.prefix(itemsToTake)
            let remainingData = indexedData.dropFirst(itemsToTake)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: spacing) {
                    camera()
                        .frame(width: columnWidth, height: columnWidth * 2 + spacing)
                        .clipped()

                    let topColumns = Array(
                        repeating: GridItem(.fixed(columnWidth), spacing: spacing,alignment: .top),
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

        case .small:
            LazyVGrid(columns: columns, spacing: theme.cellStyle.rowSpacing) {
                camera()
                ForEach(data.indices, id: \.self) { index in
                    content(data[index], index, columnWidth)
                }
                loadingCell()
            }

        case .none:
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, element in
                    content(element, index, columnWidth)
                }
                loadingCell()
            }
        }
    }
}
