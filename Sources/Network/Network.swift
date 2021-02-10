//
//  File.swift
//
//
//  Created by MoneyClip on 2021-02-09.
//

import UIKit

public final class Networking: NSObject {
    
    // MARK: - Private functions
    public static func getData(
        url: URL,
        completion: @escaping (Data?, URLResponse?, Error?) -> ()
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(
            with: request,
            completionHandler: completion
        ).resume()
    }
    
    // MARK: - Public function
    
    /// downloadImage function will download the thumbnail images
    /// returns Result<Data> as completion handler
    public static func downloadImage(url: URL,
                                     completion: @escaping (Result<Data>) -> Void) {
        Networking.getData(url: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async() {
                completion(.success(data))
            }
        }
    }
}
