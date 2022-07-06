//
//  Created by Alex.M on 04.07.2022.
//

import Foundation
import SwiftUI

public extension View {
    func mediaPicker(isPresented: Binding<Bool>,
                     limit: Int = 10,
                     onChange: @escaping MediaPickerCompletionClosure) -> some View {
        self.sheet(isPresented: isPresented) {
            MediaPicker(
                isPresented: isPresented,
                limit: limit,
                onChange: onChange
            )
        }
    }

    func mediaPicker<T>(isPresented: Binding<Bool>,
                        limit: Int = 10,
                        trailingNavigation: @escaping () -> T,
                        onChange: @escaping MediaPickerCompletionClosure) -> some View
    where T: View {
        self.sheet(isPresented: isPresented) {
            MediaPicker(
                isPresented: isPresented,
                limit: limit,
                trailingNavigation: trailingNavigation,
                onChange: onChange
            )
        }
    }

    func mediaPicker<L>(isPresented: Binding<Bool>,
                        limit: Int = 10,
                        leadingNavigation: @escaping () -> L,
                        onChange: @escaping MediaPickerCompletionClosure) -> some View
    where L: View {
        self.sheet(isPresented: isPresented) {
            MediaPicker(
                isPresented: isPresented,
                limit: limit,
                leadingNavigation: leadingNavigation,
                onChange: onChange
            )
        }
    }

    func mediaPicker<L, T>(isPresented: Binding<Bool>,
                           limit: Int = 10,
                           leadingNavigation: @escaping () -> L,
                           trailingNavigation: @escaping () -> T,
                           onChange: @escaping MediaPickerCompletionClosure) -> some View
    where L: View, T: View {
        self.sheet(isPresented: isPresented) {
            MediaPicker(
                isPresented: isPresented,
                limit: limit,
                leadingNavigation: leadingNavigation,
                trailingNavigation: trailingNavigation,
                onChange: onChange
            )
        }
    }
}
