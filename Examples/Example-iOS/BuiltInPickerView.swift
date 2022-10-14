//
//  Created by Alex.M on 05.07.2022.
//

import Foundation
import SwiftUI
import MediaPicker

struct BuiltInPickerView: View {
    @Binding var isPresented: Bool
    @Binding var medias: [Media]
    @State private var selectedMedia: [Media] = []
    let maxCount: Int = 5

    var body: some View {
        VStack {
            MediaPicker(
                isPresented: $isPresented,
                limit: maxCount,
                trailingNavigation: {
                    Text("\(selectedMedia.count) / \(maxCount) selected")
                        .font(.footnote)
                },
                onChange: { selectedMedia = $0 }
            )
            .selectionStyle(.count)
            .mediaPickerTheme(
                MediaPickerTheme(
                    selection: .init(
                        emptyTint: .white,
                        emptyBackground: .black.opacity(0.25),
                        selectedTint: .purple
                    )
                )
            )
            
            HStack {
                Button {
                    isPresented = false
                } label: {
                    Text("Cancel")
                        .foregroundColor(.black)
                }

                Spacer(minLength: 70)

                Button {
                    medias = selectedMedia
                    isPresented = false
                } label: {
                    HStack {
                        Text("Add")

                        Text("\(selectedMedia.count)")
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                }
                .background {
                    Color(hue: 0.2, saturation: 1, brightness: 0.9)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal)
        }
    }
}
