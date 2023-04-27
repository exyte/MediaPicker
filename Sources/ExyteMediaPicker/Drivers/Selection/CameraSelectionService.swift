//
//  CameraSelectionService.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI

final class CameraSelectionService: ObservableObject {

    var mediaSelectionLimit: Int? // if nill - unlimited
    var onChange: MediaPickerCompletionClosure? = nil

    @Published private(set) var selected: [URLMediaModel] = []

    var hasSelected: Bool {
        !selected.isEmpty
    }

    var fitsSelectionLimit: Bool {
        if let selectionLimit = mediaSelectionLimit {
            return selected.count < selectionLimit
        }
        return true
    }

    func canSelect(media: URLMediaModel) -> Bool {
        fitsSelectionLimit || selected.contains(media)
    }

    func onSelect(media: URLMediaModel) {
        if let index = selected.firstIndex(of: media) {
            selected.remove(at: index)
        } else {
            if fitsSelectionLimit {
                selected.append(media)
            }
        }
        onChange?(mapToMedia())
    }

    func index(of media: URLMediaModel) -> Int? {
        selected.firstIndex(of: media)
    }

    func mapToMedia() -> [Media] {
        selected
            .compactMap {
                guard $0.mediaType != nil else {
                    return nil
                }
                return Media(source: $0)
            }
    }

    func removeAll() {
        selected.removeAll()
    }
}
