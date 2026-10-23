//
//  AsyncImageLoader.swift
//  swift-concurrency
//
//  Created by Vokal-Ican on 23/10/26.
//

import UIKit

final class AsyncImageLoader {
    
    // MARK: - Singleton
    
    static let shared = AsyncImageLoader()
    
    private init () {}
    
    // MARK: - Properties
    
    private let cache = NSCache<NSURL, UIImage>()
    
    // MARK: - Cache
    
    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func save(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
