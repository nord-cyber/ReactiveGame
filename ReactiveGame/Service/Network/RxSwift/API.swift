//
//  API.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 14.03.21.
//

import Foundation


enum API:String {
    case scheme = "https"
    case host = "api.unsplash.com"
    case path = "/photos/random/"
}


protocol APIRequest {
    var method: RequestType { get }
    var parameters: [String : String] { get }
}

public enum RequestType: String {
    case GET, POST
}

class ImageRequestRx:APIRequest {
    var method: RequestType = RequestType.GET
    
    var parameters = ["client_id": Constants.accessToken]
  
}
extension APIRequest {
     func request() -> URLRequest {
        var components = URLComponents()

        components.scheme = API.scheme.rawValue
        components.host = API.host.rawValue
        components.path = API.path.rawValue
        components.queryItems = parameters.map {
            URLQueryItem(name: String($0), value: String($1))
        }

        guard let url = components.url else {
            fatalError("Could not get url")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("Accept-Version", forHTTPHeaderField: "v1")
        return request
    }
}
