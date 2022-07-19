//
//  CameraSelectionContainer.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI

struct CameraSelectionContainer: View {

    @ObservedObject var viewModel: MediaPickerViewModel

    @Binding var showingPicker: Bool

    @EnvironmentObject private var cameraSelectionService: CameraSelectionService
    @Environment(\.mediaPickerTheme) private var theme

    @State private var index: Int = 0

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    if cameraSelectionService.hasSelected {
                        viewModel.showingExitCameraConfirmation = true
                    } else {
                        viewModel.showingCameraSelection = false
                        viewModel.showingCamera = true
                    }
                }
                .foregroundColor(.white)
                .padding(.leading)
                .padding(.bottom)
                Spacer()
            }

            TabView(selection: $index) {
                ForEach(cameraSelectionService.selected.enumerated().map({ $0 }), id: \.offset) { (index, media) in
                    CameraSelectionCell(viewModel: CameraSelectionCellViewModel(media: media))
                        .tag(index)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack {
                Button("Done") {
                    viewModel.showingCameraSelection = false
                    viewModel.showingCamera = false
                    showingPicker = false
                }
                Spacer()
                Button {
                    viewModel.showingCameraSelection = false
                    viewModel.showingCamera = true
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
        .background(theme.main.fullscreenBackground)
    }
}
