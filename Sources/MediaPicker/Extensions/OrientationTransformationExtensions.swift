//
//  OrientationTransformationExtensions.swift
//  
//
//  Created by Alexandra Afonasova on 18.10.2022.
//

import UIKit
import AVFoundation

extension UIImage.Orientation {

    init(_ cgOrientation: CGImagePropertyOrientation) {
        switch cgOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }

    static func orientation(fromCGOrientationRaw cgOrientationRaw: UInt32) -> UIImage.Orientation? {
        var orientation: UIImage.Orientation?
        if let cgOrientation = CGImagePropertyOrientation(rawValue: cgOrientationRaw) {
            orientation = UIImage.Orientation(cgOrientation)
        } else {
            orientation = nil
        }
        return orientation
    }
}

extension AVCaptureVideoOrientation {

    init(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: self = .portrait
        }
    }

}
