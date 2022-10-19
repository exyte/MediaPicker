//
//  ContentView.swift
//  Example-iOS
//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
import MediaPicker
import Combine

struct ContentView: View {

    @State private var showDefaultMediaPicker = false
    @State private var showCustomizedMediaPicker = false
    @State private var medias: [Media] = []

    let columns = [GridItem(.adaptive(minimum: 100), spacing: 1, alignment: .top)]
    
    var body: some View {
        NavigationView {
            List {
                Button("Default") {
                    showDefaultMediaPicker = true
                }

                Button("Customized") {
                    showCustomizedMediaPicker = true
                }

                
                //LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(medias) { media in
                        MediaCell1(media: media)
                    }
                //}
                .padding(.horizontal)
            }
            .tint(.black)
            .navigationTitle("Examples")
        }
        // MARK: - Default media picker
        .mediaPicker(
            isPresented: $showDefaultMediaPicker,
            leadingNavigation: {
                Button("Cancel") {
                    showDefaultMediaPicker = false
                }
            },
            trailingNavigation: {
                Button("Done") {
                    showDefaultMediaPicker = false
                    print("Selected:", medias)
                }
            },
            onChange: { medias = $0 }
        )

        // MARK: - Customized media picker
        .sheet(isPresented: $showCustomizedMediaPicker) {
            BuiltInPickerView(isPresented: $showCustomizedMediaPicker, medias: $medias)
        }
    }
}

struct MediaCell1: View {

    var media: Media
    @State var url: URL?

    @State private var subscriptions = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            if let url = url {
                AsyncImage(url: url)
                    .frame(width: 100, height: 100)
            }
        }
        .task {
            url = await media.getUrl()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
