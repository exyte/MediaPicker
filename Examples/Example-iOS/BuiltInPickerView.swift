//
//  Created by Alex.M on 05.07.2022.
//

import Foundation
import SwiftUI
import MediaPicker

struct BuiltInPickerView: View {
    @Binding var isPresented: Bool
    @State private var medias: [Media] = []

    var body: some View {
        VStack {
            MediaPicker(
                isPresented: $isPresented,
                trailingNavigation: {
                    HStack {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.square.fill")
                        }
                        .tint(.red)

                        Button() {
                            print("Sent:", medias)
                        } label: {
                            Image(systemName: "checkmark.square.fill")
                        }
                        .tint(.green)
                    }
                },
                onChange: { medias = $0 }
            )
            .selectionStyle(.count)

            Text("Custom text with section count = \(medias.count)")
                .padding(.bottom)
        }
        .padding(.top)
    }
}
