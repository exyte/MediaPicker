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

    @EnvironmentObject private var appDelegate: AppDelegate
    @State private var showDefaultMediaPicker = false
    @State private var defaultMediaPickerMode = MediaPickerMode.photos
    @State private var defaultMediaPickerModeSelection = 0

    @State private var showCustomizedMediaPicker = false
    @State private var customizedMediaPickerMode = MediaPickerMode.photos

    @State private var medias: [Media] = []

    let columns = [GridItem(.flexible(), spacing: 1),
                   GridItem(.flexible(), spacing: 1),
                   GridItem(.flexible(), spacing: 1)]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Default") {
                        showDefaultMediaPicker = true
                    }
                    Button("Customized") {
                        showCustomizedMediaPicker = true
                    }
                }

                if !medias.isEmpty {
                    Section {
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(medias) { media in
                                MediaCell(media: media)
                                    .aspectRatio(1, contentMode: .fill)
                            }
                        }
                    }
                }
            }
            .foregroundColor(Color(uiColor: .label))
            .navigationTitle("Examples")
        }

        // MARK: - Default media picker
        .sheet(isPresented: $showDefaultMediaPicker) {
            MediaPicker(
                isPresented: $showDefaultMediaPicker,
                orientationHandler: {
                    switch $0 {
                    case .lock: appDelegate.lockOrientationToPortrait()
                    case .unlock: appDelegate.unlockOrientation()
                    }
                },
                onChange: { medias = $0 }
            )
            .showDefaultHeader()
            .showLiveCameraCell()
        }

        // MARK: - Customized media picker
        .sheet(isPresented: $showCustomizedMediaPicker) {
            CustomizedMediaPicker(isPresented: $showCustomizedMediaPicker, mediaPickerMode: $customizedMediaPickerMode, medias: $medias)
        }
    }
}

struct MediaCell: View {

    var media: Media
    @State var url: URL?

    var body: some View {
        GeometryReader { g in
            if let url = url {
                AsyncImage(
                    url: url,
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: g.size.width, height: g.size.width)
                            .clipped()
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
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
