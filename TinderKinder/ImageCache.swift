//
//  ImageCache.swift
//  TinderKinder
//
//  Created by Edvinas on 09/10/2018.
//  Copyright © 2018 Emenity. All rights reserved.
//

import Foundation

class ImageCache {
    private let cacheDirectory: URL
    private var cache = Set<Data>()
    
    init(cacheDirectory: URL) {
        self.cacheDirectory = cacheDirectory
        setupCache()
    }
    
    private func setupCache() {
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        let oldCache = fileURLs.compactMap { try? Data(contentsOf: $0) }
        cache = cache.union(oldCache)
    }
    
    public func exists(imageData: Data) -> Bool {
        return cache.contains(imageData)
    }
    
    public func add(imageData: Data) {
        cache.insert(imageData)
    }
}
