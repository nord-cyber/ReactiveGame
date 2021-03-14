//
//  APIAddress.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 12.03.21.
//

import UIKit
import RxSwift
import RxCocoa


struct APIAddressWithRx {
    
     func APIRandomAddressWithRX<T:Codable>(request:URLRequest) -> Observable<T>  {
   
        return Observable<T>.create { (observer)  in
            
            let session = URLSession(configuration: .default)
         
            let task = session.dataTask(with: request) { data, response, error in
                
                guard (response as? HTTPURLResponse) != nil else { return }
                
                do {
                    let data = data ?? Data()
                    
                    let responseRequest = try JSONDecoder().decode(T.self, from: data)
                    observer.onNext(responseRequest)
                } catch let error {
                    observer.onError(error)
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






