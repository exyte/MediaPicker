//
//  MediaPickerCutomizationParameters.swift
//  ExyteMediaPicker
//
//  Created by Alisa Mylnikova on 02.04.2026.
//

public struct MediaPickerCutomizationParameters {
    public var liveCameraStyle = LiveCameraCellStyle.small
    public var selectionParameters = SelectionParameters()
    public var orientationHandler: MediaPickerOrientationHandler = {_ in}
    public var didPressCancelCamera: (() -> Void)?
    public var filterClosure: MediaPicker.FilterClosure?
    public var massFilterClosure: MediaPicker.MassFilterClosure?

    public init(liveCameraStyle: LiveCameraCellStyle = LiveCameraCellStyle.prominant, selectionParameters: SelectionParameters = SelectionParameters(), orientationHandler: @escaping MediaPickerOrientationHandler = {_ in}, didPressCancelCamera: (() -> Void)? = nil, filterClosure: MediaPicker.FilterClosure? = nil, massFilterClosure: MediaPicker.MassFilterClosure? = nil) {
        self.liveCameraStyle = liveCameraStyle
        self.selectionParameters = selectionParameters
        self.orientationHandler = orientationHandler
        self.didPressCancelCamera = didPressCancelCamera
        self.filterClosure = filterClosure
        self.massFilterClosure = massFilterClosure
    }
}
