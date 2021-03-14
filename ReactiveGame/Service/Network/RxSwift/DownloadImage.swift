//
//  DownloadImage.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 12.03.21.
//

import UIKit
import RxCocoa
import RxSwift

struct DownloadImageWithRx {
    static func downloadImage(url:String) -> Observable<UIImage> {
        return Observable<UIImage>.create { (observer)  in
            guard let url = URL(string: url) else { return observer.onError(GameErrors.invalidURL) as! Disposable}
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    observer.onError(GameErrors.other(error))
                }
                if let data = data {
                    
                    guard let image = UIImage(data: data) else { return observer.onError(GameErrors.invalidImage)}
                    observer.onNext(image)
                }
                
                observer.onCompleted()
            }
            task.resume()
           return Disposables.create {
                task.cancel()
            }
        }
    }
}
