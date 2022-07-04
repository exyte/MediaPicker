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
                onChange: { medias = $0 }
            )
            .selectionStyle(.count)
            Button("Show selected (\(medias.count))") {
                print("\"Show selected\" action")
            }
        }
        .padding(.top)
    }
}
