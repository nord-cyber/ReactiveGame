//
//  ViewController.swift
//  ReactiveGame
//
//  Created by Vadzim Ivanchanka on 9.03.21.
//

import UIKit
import Combine

enum StatusGame {
    case play
    case stop
}


class GameController: UIViewController {
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
                
                
        
                self.setImages()
            }
            .store(in: &subscriptions)
    }
    
    func setImages() {
      if gameImages.count == 4 {
        for (index, gameImage) in gameImages.enumerated() {
          images[index].image = gameImage
        }
      }
    }
    
    func stopGame() {
        statusButton.setTitle("Start", for: .normal)
        
        images.forEach { $0.backgroundColor = #colorLiteral(red: 0.5277996063, green: 0.7460211515, blue: 0.6274777651, alpha: 1)}
        images.forEach{ $0.image = nil}
        counterLevel = 0
        counterScore = 0
        score.text = ""
        level.text = ""
        
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                               to: UIApplication.shared, for: nil)
    }
   
}

