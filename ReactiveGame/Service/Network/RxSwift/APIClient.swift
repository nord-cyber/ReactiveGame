//
//  APIClient.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 15.03.21.
//

import UIKit
import RxSwift


class APIClient {
    static var shared = APIClient()
    lazy var requestObservable = APIAddressWithRx()
    func getImageRx()  -> Observable<ResponseImage> {
        let rxGetUrl = ImageRequestRx()
        return requestObservable.APIRandomAddressWithRX(request: rxGetUrl.request())
    }
}
