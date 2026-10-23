//
//  OperationQueueImageLoader.swift.swift
//  swift-concurrency
//
//  Created by Vokal-Ican on 23/10/26.
//

import UIKit

final class ImageLoader {

    // MARK: - Singleton

    static let shared = ImageLoader()

    private init() {}

    // MARK: - Properties

    private let downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 4
        return queue
    }()

    private let imageCache = NSCache<NSURL, UIImage>()

    // MARK: - Cache

    func cacheImage(for url: URL) -> UIImage? {
        let image = imageCache.object(forKey: url as NSURL)
        if image != nil {
            print("Cache hit: \(url.pathComponents[2])")
        }
        return image
    }

    // MARK: - Load

    @discardableResult
    func load(_ url: URL, completion: @escaping (UIImage?) -> Void) -> Operation {
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak self, weak operation] in
            guard let operation, !operation.isCancelled else {
                print("Cancelled before download: \(url.pathComponents[2])")
                return
            }

            print("Download started: \(url.pathComponents[2])")

            guard let data = try? Data(contentsOf: url),
                  let img = UIImage(data: data) else {
                print("Download failed: \(url.pathComponents[2])")
                return
            }

            self?.imageCache.setObject(img, forKey: url as NSURL)
            print("Saved to cache: \(url.pathComponents[2])")

            guard !operation.isCancelled else {
                print("Cancelled after download: \(url.pathComponents[2])")
                return
            }

            print("Download finished: \(url.pathComponents[2])")

            OperationQueue.main.addOperation {
                completion(img)
            }
        }

        operation.completionBlock = { [weak operation] in
            guard let operation, operation.isCancelled else { return }
            print("Operation cancelled: \(url.pathComponents[2])")
        }

        downloadQueue.addOperation(operation)
        return operation
    }

    // MARK: - Cancel

    func cancelAllQueue() {
        print("Cancel all: \(downloadQueue.operationCount) operations in queue")
        downloadQueue.cancelAllOperations()
    }
}
