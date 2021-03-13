//
//  DownloadImageCombine.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 12.03.21.
//

import UIKit
import Combine

enum DownloadingImageWithCombine {
     
    static func downloadingImageWithCombine(url:String) -> AnyPublisher<UIImage, GameErrors> {
        guard let url = URL(string: url) else {
            return Fail(error: GameErrors.invalidURL).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { response -> Data in
                guard let httpResponse = response.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw GameErrors.statusCode
                }
                return response.data
            }.tryMap { (data)  in
                guard let image = UIImage(data: data) else { throw GameErrors.invalidImage}
                return image
            }
            .mapError{GameErrors.map($0)}
            .eraseToAnyPublisher()
    }
}
