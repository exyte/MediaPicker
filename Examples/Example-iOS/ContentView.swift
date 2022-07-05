//
//  ContentView.swift
//  Example-iOS
//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
import MediaPicker

struct ContentView: View {
    @State private var showDefaultMediaPicker = false
    @State private var showConfiguredMediaPicker = false
    @State private var showBuiltInMediaPicker = false
    @State private var medias: [Media] = []
    
    var body: some View {
        NavigationView {
            List {
                Text("Default")
                    .onTapGesture {
                        showDefaultMediaPicker = true
                    }
                Text("Configured")
                    .onTapGesture {
                        showConfiguredMediaPicker = true
                    }
                Text("Built-in")
                    .onTapGesture {
                        showBuiltInMediaPicker = true
                    }
            }
            .navigationTitle("Examples")
        }
        // MARK: - Default media picker
        .mediaPicker(isPresented: $showDefaultMediaPicker, onChange: { medias = $0 })

        // MARK: - Configured media picker
        .sheet(isPresented: $showConfiguredMediaPicker) {
            MediaPicker(
                isPresented: $showConfiguredMediaPicker,
                leadingNavigation: {
                    Button("Cancel") {
                        showConfiguredMediaPicker = false
                    }
                },
                trailingNavigation: {
                    Button("Send") {
                        print("Sent:", medias)
                    }
                },
                onChange: { medias = $0 }
            )
            .selectionStyle(.count)
        }

        // MARK: - Built-in media picker
        .sheet(isPresented: $showBuiltInMediaPicker) {
            BuiltInPickerView(isPresented: $showBuiltInMediaPicker)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
