//
//  ImageDownloader.swift
//  TinderKinder
//
//  Created by Edvinas on 09/10/2018.
//  Copyright © 2018 Emenity. All rights reserved.
//

import Foundation

enum ImageDownloaderError: Error {
    case invalidPath
}

struct ImageDownloader {
    private let imageDirectory: URL
    private let imageCache: ImageCache
    private let fileManager = FileManager.default
    
    init(mainDirectory: String) throws {
        guard let url = URL(string: arguments[0]) else {
            throw ImageDownloaderError.invalidPath
        }
        // Setup image directory url
        imageDirectory = url.deletingLastPathComponent().appendingPathComponent("images", isDirectory: true)
        imageCache = ImageCache(cacheDirectory: imageDirectory)
        // If directory already exists return
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: imageDirectory.path, isDirectory:&isDir) && isDir.boolValue {
            return
        }
        
        // Otherwise try to create image directory
        try createImageDirectory()
    }
    
    public func perform(request: TinderRequest) {
        request.perform { (result) in
            switch result {
            case .success(let imageData):
                self.processImage(imageData: imageData)
            case .error(let error):
                print(error)
            }
        }
    }
    
    private func createImageDirectory() throws {
        try fileManager.createDirectory(atPath: imageDirectory.path, withIntermediateDirectories: false, attributes: nil)
    }
    
    private func processImage(imageData: Data) {
        // If image already exists return
        guard imageCache.exists(imageData: imageData) == false else {
            return
        }
        
        let nextImageNumber = getNextImageNumber()
        let nextImageURLPath = imageDirectory.appendingPathComponent("\(nextImageNumber).jpeg").path
        let nextImageURL = URL(fileURLWithPath: nextImageURLPath)
        
        do {
            try imageData.write(to: nextImageURL)
            imageCache.add(imageData: imageData)
            print("Someone liked you!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Using this instead of getting count from cache in case if
    // program is terminated and cache is emptied
    private func getNextImageNumber() -> Int {
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil) else {
            // If directory does not exist, create one and call same function
            do {
                try createImageDirectory()
            } catch {
                // If we are at this stage we should crash
                fatalError("Failed to create image directory, exiting the app")
            }
            return getNextImageNumber()
        }
        // Using existing images determine name for next image
        let numbers = fileURLs.compactMap { Int($0.deletingPathExtension().lastPathComponent) }
        return (numbers.max() ?? 0) + 1
    }
}
