//
//  Created by Alex.M on 08.06.2022.
//

import Foundation
import SwiftUI
import Photos

final class SelectionService: ObservableObject {

    var mediaSelectionLimit: Int?

    @Published private(set) var selected: [AssetMediaModel] = [] {
        didSet {
            selectionIndices = Dictionary(uniqueKeysWithValues: selected.enumerated().map { ($1.id, $0) })
        }
    }
    
    @Published private(set) var selectionIndices: [AssetMediaModel.ID: Int] = [:]

    var canSendSelected: Bool {
        !selected.isEmpty
    }

    var fitsSelectionLimit: Bool {
        if let selectionLimit = mediaSelectionLimit {
            return selected.count < selectionLimit
        }
        return true
    }

    func canSelect(_ assetMediaModel: AssetMediaModel) -> Bool {
        fitsSelectionLimit || selected.contains(assetMediaModel)
    }

    func selectionIndex(_ assetMediaModel: AssetMediaModel) -> Int? {
        selectionIndices[assetMediaModel.id]
    }

    func onSelect(assetMediaModel: AssetMediaModel) {
        if let index = selected.firstIndex(of: assetMediaModel) {
            selected.remove(at: index)
        } else if fitsSelectionLimit {
            selected.append(assetMediaModel)
        }
    }

    func index(of assetMediaModel: AssetMediaModel) -> Int? {
        selected.firstIndex(of: assetMediaModel)
    }

    func removeAll() {
        selected.removeAll()
    }

    func setInitialSelection(_ models: [AssetMediaModel]) {
        selected = models
    }

    func updateSelection(with models: [AssetMediaModel]) {
        selected = selected.filter {
            models.contains($0)
        }
    }
}
