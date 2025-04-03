//
//  View+NotificationCenter.swift
//  
//
//  Created by Alexandra Afonasova on 17.10.2022.
//

import SwiftUI

extension View {
    @MainActor func onRotate(perform: @escaping (UIDeviceOrientation) -> Void) -> some View {
        let publisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        return onReceive(publisher) { _ in perform(UIDevice.current.orientation) }
    }
}
