//
//  Created by Alex.M on 06.07.2022.
//

import Foundation
import SwiftUI

public struct MediaPickerTheme: Sendable {
    public let main: Main
    public let selection: Selection
    public let cellStyle: CellStyle
    public let error: Error
    public let defaultHeader: DefaultHeader

    public init(main: MediaPickerTheme.Main = .init(),
                selection: MediaPickerTheme.Selection = .init(),
                cellStyle: MediaPickerTheme.CellStyle = .init(),
                error: MediaPickerTheme.Error = .init(),
                defaultHeader: MediaPickerTheme.DefaultHeader = .init()) {
        self.main = main
        self.selection = selection
        self.cellStyle = cellStyle
        self.error = error
        self.defaultHeader = defaultHeader
    }
}

extension MediaPickerTheme {
    public struct Main: Sendable {
        public let pickerText: Color
        public let pickerBackground: Color
        public let fullscreenPhotoBackground: Color
        public let cameraText: Color
        public let cameraBackground: Color
        public let cameraSelectionText: Color
        public let cameraSelectionBackground: Color

        public init(
            pickerText: Color = Color("pickerText", bundle: .current),
            pickerBackground: Color = Color("pickerBG", bundle: .current),
            fullscreenPhotoBackground: Color = Color("pickerBG", bundle: .current),
            cameraText: Color = Color("cameraText", bundle: .current),
            cameraBackground: Color = Color("cameraBG", bundle: .current),
            cameraSelectionText: Color = Color("cameraText", bundle: .current),
            cameraSelectionBackground: Color = Color("cameraBG", bundle: .current)
        ) {
            self.pickerText = pickerText
            self.pickerBackground = pickerBackground
            self.fullscreenPhotoBackground = fullscreenPhotoBackground
            self.cameraText = cameraText
            self.cameraBackground = cameraBackground
            self.cameraSelectionText = cameraSelectionText
            self.cameraSelectionBackground = cameraSelectionBackground
        }
    }

    public struct Selection: Sendable {
        public let cellEmptyBorder: Color
        public let cellEmptyBackground: Color
        public let cellSelectedBorder: Color
        public let cellSelectedBackground: Color
        public let cellSelectedCheckmark: Color
        public let fullscreenEmptyBorder: Color
        public let fullscreenEmptyBackground: Color
        public let fullscreenSelectedBorder: Color
        public let fullscreenSelectedBackground: Color
        public let fullscreenSelectedCheckmark: Color

        public init(
            cellEmptyBorder: Color = .white,
            cellEmptyBackground: Color = .black.opacity(0.25),
            cellSelectedBorder: Color = .white,
            cellSelectedBackground: Color = Color("selection", bundle: .current),
            cellSelectedCheckmark: Color = .white,
            fullscreenEmptyBorder: Color = Color("selection", bundle: .current),
            fullscreenEmptyBackground: Color = .clear,
            fullscreenSelectedBorder: Color = Color("selection", bundle: .current),
            fullscreenSelectedBackground: Color = Color("selection", bundle: .current),
            fullscreenSelectedCheckmark: Color = .white
        ) {
            self.cellEmptyBorder = cellEmptyBorder
            self.cellEmptyBackground = cellEmptyBackground
            self.cellSelectedBorder = cellSelectedBorder
            self.cellSelectedBackground = cellSelectedBackground
            self.cellSelectedCheckmark = cellSelectedCheckmark
            self.fullscreenEmptyBorder = fullscreenEmptyBorder
            self.fullscreenEmptyBackground = fullscreenEmptyBackground
            self.fullscreenSelectedBorder = fullscreenSelectedBorder
            self.fullscreenSelectedBackground = fullscreenSelectedBackground
            self.fullscreenSelectedCheckmark = fullscreenSelectedCheckmark
        }

        public init(
            accent: Color,
            tint: Color = .white,
            background: Color = .black.opacity(0.25)
        ) {
            self.init(
                cellEmptyBorder: tint,
                cellEmptyBackground: background,
                cellSelectedBorder: tint,
                cellSelectedBackground: accent,
                cellSelectedCheckmark: tint,
                fullscreenEmptyBorder: accent,
                fullscreenEmptyBackground: .clear,
                fullscreenSelectedBorder: accent,
                fullscreenSelectedBackground: accent,
                fullscreenSelectedCheckmark: tint
            )
        }
    }

    public struct CellStyle: Sendable {
        public let columnsSpacing: CGFloat
        public let rowSpacing: CGFloat
        public let cornerRadius: CGFloat

        public init(columnsSpacing: CGFloat = 1,
                    rowSpacing: CGFloat = 1,
                    cornerRadius: CGFloat = 0) {
            self.columnsSpacing = columnsSpacing
            self.rowSpacing = rowSpacing
            self.cornerRadius = cornerRadius
        }
    }

    public struct Error: Sendable {
        public let background: Color
        public let tint: Color

        public init(background: Color = .red.opacity(0.7),
                    tint: Color = Color("cameraText", bundle: .current)) {
            self.background = background
            self.tint = tint
        }
    }

    public struct DefaultHeader: Sendable {
        public let background: Color

        public init(background: Color = Color("pickerBG", bundle: .current),
                    segmentTintColor: Color = Color("pickerBG", bundle: .current),
                    selectedSegmentTintColor: Color = Color("pickerBG", bundle: .current),
                    selectedText: Color = Color("pickerText", bundle: .current),
                    unselectedText: Color = Color("pickerText", bundle: .current)) {
            self.background = background

            DispatchQueue.main.async {
                UISegmentedControl.appearance().backgroundColor = UIColor(segmentTintColor)
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(selectedSegmentTintColor)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(selectedText)], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(unselectedText)], for: .normal)
            }
        }
    }
}
