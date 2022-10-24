//
//  Created by Alex.M on 05.07.2022.
//

import Foundation
import SwiftUI
import MediaPicker

struct CustomizedMediaPicker: View {

    @EnvironmentObject private var appDelegate: AppDelegate

    @Binding var isPresented: Bool
    @Binding var mediaPickerMode: MediaPickerMode
    @Binding var medias: [Media]

    @State private var selectedMedia: [Media] = []
    @State private var albums: [AlbumModel] = []

    @State private var showAlbumsDropDown: Bool = false
    @State private var selectedAlbum: AlbumModel?

    let maxCount: Int = 5

    var body: some View {
        VStack {
            headerView

            MediaPicker(
                isPresented: $isPresented,
                pickerMode: $mediaPickerMode,
                limit: maxCount,
                orientationHandler: {
                    if $0 {
                        appDelegate.lockOrientationToPortrait()
                    } else {
                        appDelegate.unlockOrientation()
                    }
                },
                onChange: { selectedMedia = $0 }
            )
            .albums($albums)
            .selectionStyle(.count)
            .mediaPickerTheme(
                MediaPickerTheme(
                    main: .init(
                        background: .black
                    ),
                    selection: .init(
                        emptyTint: .white,
                        emptyBackground: .black.opacity(0.25),
                        selectedTint: .purple
                    )
                )
            )
            .overlay(alignment: .topLeading) {
                if showAlbumsDropDown {
                    albumsDropdown
                        .padding(15)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(5)
                }
            }
            
            footerView
        }
        .background(Color.black)
        .foregroundColor(.white)
    }

    var headerView: some View {
        HStack {
            Text(selectedAlbum?.title ?? "Recents").onTapGesture {
                showAlbumsDropDown.toggle()
            }

            Spacer()

            Text("\(selectedMedia.count) out of \(maxCount) selected")
        }
        .padding()
    }

    var footerView: some View {
        HStack {
            Button {
                isPresented = false
            } label: {
                Text("Cancel")
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

    var albumsDropdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(albums) { album in
                Button(album.title ?? "") {
                    selectedAlbum = album
                    mediaPickerMode = .album(album)
                    showAlbumsDropDown = false
                }
            }
        }
    }
}
