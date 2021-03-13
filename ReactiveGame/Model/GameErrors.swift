//
//  Error.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 12.03.21.
//

import Foundation


enum GameErrors: Error {
    case statusCode
    case decoding
    case invalidImage
    case invalidURL
    case other(Error)
    
    static func map(_ error:Error) -> GameErrors{
        return  (error as? GameErrors) ?? .other(error)
    }
}

