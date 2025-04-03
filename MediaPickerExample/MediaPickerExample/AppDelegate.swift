//
//  AppDelegate.swift
//  Example-iOS
//
//  Created by Alexandra Afonasova on 20.10.2022.
//

import Foundation
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    private var orientationLock = UIInterfaceOrientationMask.all

    func lockOrientationToPortrait() {
        orientationLock = .portrait
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }

    func unlockOrientation() {
        orientationLock = .all
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let currentOrientation = UIDevice.current.orientation
            let newOrientation: UIInterfaceOrientationMask

            switch currentOrientation {
            case .portrait: newOrientation = .portrait
            case .portraitUpsideDown: newOrientation = .portraitUpsideDown
            case .landscapeLeft: newOrientation = .landscapeLeft
            case .landscapeRight: newOrientation = .landscapeRight
            default: newOrientation = .all
            }

            scene.requestGeometryUpdate(.iOS(interfaceOrientations: newOrientation))
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

}
