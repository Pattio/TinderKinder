//
//  TinderRequest.swift
//  TinderKinder
//
//  Created by Edvinas on 09/10/2018.
//  Copyright © 2018 Emenity. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(String)
}

class TinderRequest {
    private let request: URLRequest
    private let session: URLSession
    private var task: URLSessionDataTask?
    private let apiURL = URL(string: "https://api.gotinder.com/v2/fast-match/preview")!
    
    init(authToken: String) {
        // Create request without cache
        var newRequest = URLRequest(url: apiURL)
        newRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        newRequest.addValue(authToken, forHTTPHeaderField: "X-Auth-Token")
        // Create session configuration without cache
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.urlCache = nil
        
        session = URLSession(configuration: configuration)
        request = newRequest
    }
    
    public func perform(completion: @escaping (Result<Data>)->()) {
        task?.cancel()
        task = nil
        task = session.dataTask(with: request) { (data, response, error) in
            // If there was an error return
            if let error = error {
                completion(.error(error.localizedDescription))
                return
            }
            // If response is not an image return
            guard let data = data else {
                completion(.error("Response is not an image"))
                return
            }
            completion(.success(data))
        }
        task?.resume()
    }
}
