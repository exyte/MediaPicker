//
//  PublicAPI.swift
//  ExyteMediaPicker
//
//  Created by Alisa Mylnikova on 02.04.2026.
//

import SwiftUI

public extension MediaPicker {

    func liveCameraCell(_ style: LiveCameraCellStyle = .small) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.mediaPickerParams.liveCameraStyle = style
        return mediaPicker
    }

    @available(*, deprecated, message: "use liveCameraCell instead")
    func showLiveCameraCell(_ show: Bool = true) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.mediaPickerParams.liveCameraStyle = show ? .small : .none
        return mediaPicker
    }

    func mediaSelectionType(_ type: MediaSelectionType) -> MediaPicker {
        mediaPickerParams.selectionParameters.mediaType = type
        return self
    }

    func mediaSelectionStyle(_ style: MediaSelectionStyle) -> MediaPicker {
        mediaPickerParams.selectionParameters.selectionStyle = style
        return self
    }

    func mediaSelectionLimit(_ limit: Int) -> MediaPicker {
        mediaPickerParams.selectionParameters.selectionLimit = limit
        return self
    }

    func showFullscreenPreview(_ show: Bool) -> MediaPicker {
        mediaPickerParams.selectionParameters.showFullscreenPreview = show
        return self
    }

    func setMediaPickerParameters(_ params: MediaPickerCutomizationParameters) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.mediaPickerParams = params
        return mediaPicker
    }

    func setSelectionParameters(_ params: SelectionParameters) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.mediaPickerParams.selectionParameters = params
        return mediaPicker
    }

    func applyFilter(_ filterClosure: @escaping FilterClosure) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.mediaPickerParams.filterClosure = filterClosure
        return mediaPicker
    }

    func applyFilter(_ filterClosure: @escaping MassFilterClosure) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.mediaPickerParams.massFilterClosure = filterClosure
        return mediaPicker
    }

    func didPressCancelCamera(_ didPressCancelCamera: @escaping ()->()) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.mediaPickerParams.didPressCancelCamera = didPressCancelCamera
        return mediaPicker
    }

    func orientationHandler(_ orientationHandler: @escaping MediaPickerOrientationHandler) -> MediaPicker {
        var mediaPicker = self
        mediaPicker.mediaPickerParams.orientationHandler = orientationHandler
        return mediaPicker
    }
}

