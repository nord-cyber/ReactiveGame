//
//  ViewController.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 9.03.21.
//

import UIKit
import Combine
import RxSwift
import RxCocoa

enum StatusGame {
    case play
    case stop
}


final class GameController: UIViewController {
    var subscriptions: Set<AnyCancellable> = []
   
    var gameImages = [UIImage]()
    var gameStatus:StatusGame = .stop {
        didSet {
            switch gameStatus {
            case .play:
                playInGame()
            case .stop:
                stopGame()
            }
        }
    }
    
    var counterLevel = Int()
    var counterScore = Int()
    
    @IBOutlet var images: [UIImageView]!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var statusButton: UIButton!
    @IBOutlet var level:UILabel!
    @IBOutlet var score:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images.forEach { $0.backgroundColor = #colorLiteral(red: 0.5277996063, green: 0.7460211515, blue: 0.6274777651, alpha: 1)}
    }
    
    
    @IBAction func changeStatusButton(_ sender: UIButton) {
        gameStatus = gameStatus == StatusGame.stop ? .play : .stop
    }
    

    @IBAction func tapImageButton(_ sender: UIButton) {
        print("hey! \(sender.tag)")
    }
    
    
    func playInGame() {
        statusButton.setTitle("Stop", for: .normal)
        
        counterLevel += 1
        level.text = "Level: \(counterLevel)"
        
        counterScore += 100
        score.text = "Score: \(counterScore)"
        
        
      //rx realization
        getImageRx()
        
    // combine realization
      // getImageCombine()
           
}
    
    fileprivate func shuffledImage(first:UIImage,second:UIImage) {
        self.gameImages = [first,first,first,second].shuffled()
        self.setImagesInIcons()
    }
    
        
   fileprivate func setImagesInIcons() {
      if gameImages.count == 4 {
        for (index, gameImage) in gameImages.enumerated() {
          images[index].image = gameImage
        }
      }
    }
    
    fileprivate  func stopGame() {
        statusButton.setTitle("Start", for: .normal)
        
        images.forEach { $0.backgroundColor = #colorLiteral(red: 0.5277996063, green: 0.7460211515, blue: 0.6274777651, alpha: 1)}
        images.forEach{ $0.image = nil}
        counterLevel = 0
        counterScore = 0
        score.text = ""
        level.text = ""
        
//        UIControl().sendAction(#selector(NSXPCConnection.suspend),
//                               to: UIApplication.shared, for: nil)
    }
   
}

// MARK: BUG WITH IMAGES
extension GameController {
    //MARK: RX
    fileprivate func getImageRx() {
     
        var firstImage:UIImage!
        getImageFromRx { (image) in
            firstImage = image
        }
        var secondImage:UIImage!
        getImageFromRx { (image) in
            secondImage = image
        }
        
        
        
//       Observable<UIImage?>.from([firstImage,secondImage])
//            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
//            .subscribe { (event) in
//                if firstImage != nil, secondImage != nil {
//                    self.shuffledImage(first: firstImage, second: secondImage)
//                }
//            }
        
        
    }
    
    fileprivate func getImageFromRx(completionHandler:@escaping ((UIImage)->())) {
        let clientRx = APIClient.shared
            _ = clientRx.getImageRx()
                .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { (response) in
                    guard let regularImage = response.element?.urls.regular else { return }
                _ =  DownloadImageWithRx.downloadImage(url: regularImage)
                        .observe(on: ConcurrentDispatchQueueScheduler.init(queue: .main))
                        .subscribe { image in
                            guard let image = image.element else { return }
                            completionHandler(image)
                            
                        }
                }
    }

    
    
    //MARK: Combine
    fileprivate func getImageCombine() {
        let notDifferentImage = APIAddressWithCombine.APIRandomImageWithCombine().flatMap { responseImage in
            DownloadingImageWithCombine.downloadingImageWithCombine(url: responseImage.urls.regular)
        }
        let differentImage = APIAddressWithCombine.APIRandomImageWithCombine().flatMap { responseImage in
            DownloadingImageWithCombine.downloadingImageWithCombine(url: responseImage.urls.regular)
        }
        
        notDifferentImage.zip(differentImage)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                  print("Error: \(error)")
                  self.gameStatus = .stop
                  
                }
            } receiveValue: { [unowned self] first, second in
                self.gameImages = [first,second, second, second].shuffled()
                self.score.text = "Score: \(self.counterScore)"
    
                //TODO: handling game score
                self.setImagesInIcons()
            }
            .store(in: &subscriptions)
    }
}

