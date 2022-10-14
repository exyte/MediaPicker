//
//  CameraSelectionService.swift
//  
//
//  Created by Alisa Mylnikova on 12.07.2022.
//

import SwiftUI

final class CameraSelectionService: ObservableObject {

    var mediaSelectionLimit: Int?
    var onChange: MediaPickerCompletionClosure? = nil

    private var selectionLimit: Int {
        mediaSelectionLimit ?? 0
    }

    @Published private(set) var selected: [URLMediaModel] = []

    var hasSelected: Bool {
        !selected.isEmpty
    }

    func canSelect(media: URLMediaModel) -> Bool {
        selected.count < selectionLimit || selected.contains(media)
    }

    func onSelect(media: URLMediaModel) {
        if let index = selected.firstIndex(of: media) {
            selected.remove(at: index)
        } else {
            if selected.count < selectionLimit {
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
                guard let type = $0.mediaType else {
                    return nil
                }
                return Media(type: type, source: .url($0.url))
            }
    }

    func removeAll() {
        selected.removeAll()
    }
}
