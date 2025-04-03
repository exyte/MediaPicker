//
//  File.swift
//  
//
//  Created by Alisa Mylnikova on 04.09.2023.
//

import SwiftUI

extension View {
    func dismissKeyboard() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

extension Shape {
    func styled(_ foregroundColor: Color, border borderColor: Color = .clear, _ borderWidth: CGFloat = 0) -> some View {
        self.foregroundStyle(foregroundColor)   // Apply foreground color
            .overlay {
                self
                    .stroke(borderColor, lineWidth: borderWidth)  // Apply border color and width
            }
    }
}

extension View {
    func padding(_ horizontal: CGFloat, _ vertical: CGFloat) -> some View {
        self.padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
    }

    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}
