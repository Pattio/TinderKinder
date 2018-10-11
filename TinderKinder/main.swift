//
//  main.swift
//  TinderKinder
//
//  Created by Edvinas on 08/10/2018.
//  Copyright © 2018 Emenity. All rights reserved.
//

import Foundation

let fileManager = FileManager.default
let arguments = CommandLine.arguments
let imageDownloader: ImageDownloader

guard arguments.count == 3 else {
    print("Usage ./TinderKinder <X-Auth-Token> <Fetch Time Interval (s)>")
    exit(0)
}

guard let timeInterval = UInt32(arguments[2]) else {
    print("Time Interval must be positive integer")
    exit(0)
}

do {
    try imageDownloader = ImageDownloader(mainDirectory: arguments[0])
} catch ImageDownloaderError.invalidPath {
    print("Invalid path provided as first argument")
    exit(0)
} catch let error  {
    print(error.localizedDescription)
    exit(0)
}

let request = TinderRequest(authToken: arguments[1])
while true {
    print("Fetching server")
    imageDownloader.perform(request: request)
    sleep(timeInterval)
}
