//
//  APIAddressCombine.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 12.03.21.
//

import UIKit
import Combine

enum APIAddressWithCombine {
    // Return type of parsing images or error
    static func APIRandomImageWithCombine() -> AnyPublisher<ResponseImage, GameErrors>  {
        
        let url = URL(string: "https://api.unsplash.com/photos/random/?client_id=\(Constants.accessToken)")!
       
        
        // create config for session
        let config =  URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession(configuration: config)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Accept-Version", forHTTPHeaderField: "v1")
        
       return session.dataTaskPublisher(for: urlRequest)
            .tryMap { response in
                guard let httpURLResponse = response.response as? HTTPURLResponse,
                      httpURLResponse.statusCode == 200
                else { throw GameErrors.statusCode}
                
                return response.data
            }
        .decode(type: ResponseImage.self, decoder: JSONDecoder())
        .mapError { GameErrors.map($0) }
        .eraseToAnyPublisher()
    }
}
