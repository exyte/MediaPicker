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
    @State private var albums: [Album] = []

    @State private var showAlbumsDropDown: Bool = false
    @State private var selectedAlbum: Album?

    let maxCount: Int = 5

    var body: some View {
        VStack {
            headerView

            MediaPicker(
                isPresented: $isPresented,
                limit: maxCount,
                orientationHandler: {
                    switch $0 {
                    case .lock: appDelegate.lockOrientationToPortrait()
                    case .unlock: appDelegate.unlockOrientation()
                    }
                },
                onChange: { selectedMedia = $0 }
            )
            .albums($albums)
            .pickerMode($mediaPickerMode)
            .selectionStyle(.count)
            .mediaPickerTheme(
                main: .init(
                    background: .black
                ),
                selection: .init(
                    emptyTint: .white,
                    emptyBackground: .black.opacity(0.25),
                    selectedTint: Color("CustomPurple")
                )
            )
            .overlay(alignment: .topLeading) {
                if showAlbumsDropDown {
                    albumsDropdown
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(5)
                }
            }

            Spacer()
            
            footerView
        }
        .background(Color.black)
        .foregroundColor(.white)
    }

    var headerView: some View {
        HStack {
            HStack {
                Text(selectedAlbum?.title ?? "Recents")
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(radians: showAlbumsDropDown ? .pi : 0))
            }
            .onTapGesture {
                withAnimation {
                    showAlbumsDropDown.toggle()
                }
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
                    .foregroundColor(.white.opacity(0.7))
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
                Color("CustomGreen")
                    .cornerRadius(16)
            }
        }
        .padding(.horizontal)
    }

    var albumsDropdown: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(albums) { album in
                    Button(album.title ?? "") {
                        selectedAlbum = album
                        mediaPickerMode = .album(album)
                        showAlbumsDropDown = false
                    }
                }
            }
            .padding(15)
        }
        .frame(maxHeight: 300)
    }
}
