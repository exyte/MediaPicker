//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

struct PermissionActionView: View {

    enum PermissionType {
        case library(PermissionsService.PhotoLibraryPermissionStatus)
        case camera(PermissionsService.CameraPermissionStatus)
    }

    let type: PermissionType

    @State private var showSheet = false
    
    var body: some View {
        ZStack {
            if showSheet {
                LimitedLibraryPickerProxyView(isPresented: $showSheet) {
                    DispatchQueue.main.async {
                        PermissionsService.shared.updatePhotoLibraryAuthorizationStatus()
                    }
                }
                .frame(width: 1, height: 1)
            }
            
            switch type {
            case .library(let status):
                buildLibraryActionView(status)
            case .camera(let status):
                buildCameraActionView(status)
            }
        }
    }
}

private extension PermissionActionView {
    
    @ViewBuilder
    func buildLibraryActionView(_ status: PermissionsService.PhotoLibraryPermissionStatus) -> some View {
        switch status {
        case .authorized, .unknown:
            EmptyView()
        case .limited:
            PermissionsErrorView(text: "Setup Photos access to see more photos here") {
                showSheet = true
            }
        case .unavailable:
            goToSettingsButton(text: "Allow Photos access in settings to see photos here")
        }
    }
    
    @ViewBuilder
    func buildCameraActionView(_ status: PermissionsService.CameraPermissionStatus) -> some View {
        switch status {
        case .authorized, .unknown:
            EmptyView()
        case .unavailable:
            goToSettingsButton(text: "Allow Camera access in settings to see live preview")
        }
    }
    
    func goToSettingsButton(text: String) -> some View {
        PermissionsErrorView(
            text: text,
            action: {
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        )
    }
}
