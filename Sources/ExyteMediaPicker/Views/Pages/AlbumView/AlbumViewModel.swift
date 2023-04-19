//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine

final class AlbumViewModel: ObservableObject {

    @Published var title: String? = nil
    @Published var medias: [AssetMediaModel] = []
    @Published var isLoading: Bool = false
    
    let mediasProvider: MediasProviderProtocol

    private var mediaCancellable: AnyCancellable?
    
    init(mediasProvider: MediasProviderProtocol) {
        self.mediasProvider = mediasProvider
        onStart()
    }
    
    func onStart() {
        mediaCancellable = mediasProvider.medias
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.medias = $0
            }
        
        mediasProvider.reload()
    }
    
    func onStop() {
        mediaCancellable = nil
    }
}
