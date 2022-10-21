//
//  Created by Alex.M on 31.05.2022.
//

import Foundation
import Combine
import Photos

#if os(iOS)
import UIKit.UIImage
import UIKit.UIScreen
#endif

extension PHAsset {
    actor RequestStore {
        var request: Request?
        
        func storeRequest(_ request: Request) {
            self.request = request
        }
        
        func cancel(asset: PHAsset) {
            switch request {
            case .contentEditing(let id):
                asset.cancelContentEditingInputRequest(id)
            case .imageRequest(let id):
                PHImageManager.default().cancelImageRequest(id)
            case .none:
                break
            }
        }
    }
    
    enum Request {
        case contentEditing(PHContentEditingInputRequestID)
        case imageRequest(PHImageRequestID)
    }
    
    func getURL(completion: @escaping (URL?) -> Void) -> Request? {
        var request: Request?
        
        if mediaType == .image {
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { _ -> Bool in
                return true
            }
            request = .contentEditing(
                requestContentEditingInput(
                    with: options,
                    completionHandler: { (contentEditingInput, _) in
                        completion(contentEditingInput?.fullSizeImageURL)
                    }
                )
            )
        } else if mediaType == .video {
            let options = PHVideoRequestOptions()
            options.version = .original
            request = .imageRequest(
                PHImageManager
                    .default()
                    .requestAVAsset(
                        forVideo: self,
                        options: options,
                        resultHandler: { (asset, _, _) in
                            if let urlAsset = asset as? AVURLAsset {
                                completion(urlAsset.url)
                            } else {
                                completion(nil)
                            }
                        }
                    )
            )
        }
        
        return request
    }

    var formattedDuration: String? {
        guard mediaType == .video || mediaType == .audio else {
            return nil
        }
        return duration.formatted()
    }
}

extension PHAsset {
    func getURL() async -> URL? {
        let requestStore = RequestStore()
        
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let request = getURL { url in
                    continuation.resume(returning: url)
                }
                if let request = request {
                    Task {
                        await requestStore.storeRequest(request)
                    }
                }
            }
        } onCancel: {
            Task {
                await requestStore.cancel(asset: self)
            }
        }

    }
}

#if os(iOS)
extension PHAsset {

    func image(size: CGSize) -> AnyPublisher<UIImage?, Never> {
        let requestSize = CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale)
        let passthroughSubject = PassthroughSubject<UIImage?, Never>()
        var requestID: PHImageRequestID?
        
        let result = passthroughSubject
            .handleEvents(receiveSubscription: { _ in
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .opportunistic
                
                requestID = PHCachingImageManager.default().requestImage(
                    for: self,
                    targetSize: requestSize,
                    contentMode: .aspectFill,
                    options: options,
                    resultHandler: { image, info in
                        passthroughSubject.send(image)
                        if info?.keys.contains(PHImageResultIsDegradedKey) == false {
                            passthroughSubject.send(completion: .finished)
                        }
                    }
                )
            }, receiveCancel: {
                if let requestID = requestID {
                    PHCachingImageManager.default().cancelImageRequest(requestID)
                }
            })
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return result
    }

    func data() async -> Data? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true

            PHCachingImageManager.default().requestImageDataAndOrientation(
                for: self,
                options: options,
                resultHandler: { data, _, _, info in
                    guard info?.keys.contains(PHImageResultIsDegradedKey) == true
                    else { fatalError("PHImageManager with `options.isSynchronous = true` should call result ONE time.") }
                    continuation.resume(returning: data)
                }
            )
        }
    }
}
#endif
