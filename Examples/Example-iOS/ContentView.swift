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
    @State private var defaultMediaPickerMode = MediaPickerMode.photos
    @State private var defaultMediaPickerModeSelection = 0

    @State private var showCustomizedMediaPicker = false
    @State private var customizedMediaPickerMode = MediaPickerMode.photos

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
                        MediaCell(media: media)
                    }
                //}
                .padding(.horizontal)
            }
            .foregroundColor(Color(uiColor: .label))
            .navigationTitle("Examples")
        }

        // MARK: - Default media picker
        .sheet(isPresented: $showDefaultMediaPicker) {
            VStack {
                headerView
                    .padding(12)
                    .background(Material.regular)

                MediaPicker(isPresented: $showDefaultMediaPicker, pickerMode: $defaultMediaPickerMode) {
                    medias = $0
                }
            }
        }

        // MARK: - Customized media picker
        .sheet(isPresented: $showCustomizedMediaPicker) {
            CustomizedMediaPicker(isPresented: $showCustomizedMediaPicker, mediaPickerMode: $customizedMediaPickerMode, medias: $medias)
        }
    }

    var headerView: some View {
        HStack {
            Button("Cancel") {
                showDefaultMediaPicker = false
            }

            Spacer()

            Picker("", selection: $defaultMediaPickerModeSelection) {
                Text("Photos")
                    .tag(0)
                Text("Albums")
                    .tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: UIScreen.main.bounds.width / 2)
            .onChange(of: defaultMediaPickerModeSelection) { newValue in
                defaultMediaPickerMode = defaultMediaPickerModeSelection == 0 ? .photos : .albums
            }

            Spacer()

            Button("Done") {
                showDefaultMediaPicker = false
                print("Selected:", medias)
            }
        }
    }
}

struct MediaCell: View {

    var media: Media
    @State var url: URL?

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
