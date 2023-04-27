//
//  CameraSelectionContainer.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI

public struct CameraSelectionView: View {

    @EnvironmentObject private var cameraSelectionService: CameraSelectionService

    @State private var index: Int = 0

    public var body: some View {
        TabView(selection: $index) {
            ForEach(cameraSelectionService.selected.enumerated().map({ $0 }), id: \.offset) { (index, mediaModel) in
                FullscreenCell(viewModel: FullscreenCellViewModel(mediaModel: mediaModel))
                    .tag(index)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct DefaultCameraSelectionContainer: View {

    @EnvironmentObject private var cameraSelectionService: CameraSelectionService
    @Environment(\.mediaPickerTheme) private var theme

    @ObservedObject var viewModel: MediaPickerViewModel

    @Binding var showingPicker: Bool

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    viewModel.onCancelCameraSelection(cameraSelectionService.hasSelected)
                }
                .foregroundColor(.white)
                Spacer()
            }
            .padding()

            CameraSelectionView()

            HStack {
                Button("Done") {
                    showingPicker = false
                }
                Spacer()
                Button {
                    viewModel.setPickerMode(.camera)
                } label: {
                    Image(systemName: "plus.app")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .foregroundColor(.white)
            .font(.system(size: 16))
            .padding()
        }
        .background(theme.main.cameraSelectionBackground)
    }
}
