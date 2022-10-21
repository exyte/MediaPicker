//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine

final class AlbumViewModel: ObservableObject {
    // MARK: - Values
    // MARK: Public
    @Published var title: String? = nil
    @Published var medias: [AssetMediaModel] = []
    @Published var isLoading: Bool = false
    
    let mediasProvider: MediasProviderProtocol

    // MARK: Private
    private var mediaCancellable: AnyCancellable?
    
    // MARK: - Object life cycle
    
    init(mediasProvider: MediasProviderProtocol) {
        self.mediasProvider = mediasProvider
        onStart()
    }
    
    // MARK: - Public methods
    func onStart() {
        mediaCancellable = mediasProvider.medias
            .sink(receiveValue: { [weak self] in
                self?.medias = $0
            })
        
        mediasProvider.reload()
    }
    
    func onStop() {
        mediaCancellable = nil
    }
}
