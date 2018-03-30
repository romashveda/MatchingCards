//
//  ViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/3/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

struct Image: Decodable {
    var name: String
    var link: URL
}

class CardCollectionViewController: UIViewController{
    
    var timer = Timer()
    var counter = 0.0
    var isRuning = false
    var flippedCardsCount = 0 // counts amount of already flipped cards
    var firstCard: IndexPath = [] // here will be indexpath of first flipped card
    var index = 0
    var numberOfCards = 0
    var scores = 0{
        didSet{
            score.text = "Score: \(scores)"
        }
    }
    var images = [Image]()
    var selectedImages = [Image]()
    
    @IBOutlet weak var cardsCollection: UICollectionView!
    @IBOutlet weak var score: UILabel!
    
    let group = DispatchGroup.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImage()
    }
    
    func startTime(){
        if(isRuning == false){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isRuning = true
        }
    }
    
    @objc func updateTimer(){
        counter+=0.1
        timerLabel.text = String(format: "%.1f",counter)
    }
    
    @IBOutlet weak var timerLabel: UILabel!{
        didSet{
            timerLabel.text = "\(counter)"
        }
    }
    
    func getImage(){
        print(images.count)
        var unShuffled = [Image]()
        for _ in 0..<numberOfPairsOfCards{
            let randomInt = (images.count - 1).arc4random
            let randomImage = images.remove(at: randomInt)
            unShuffled+=[randomImage,randomImage]
        }
        while !unShuffled.isEmpty{
            let randomIndex = unShuffled.count.arc4random
            selectedImages.append(unShuffled.remove(at: randomIndex))
        }
    }    
    
    func flipUp(for cell: CollectionViewCell){
        cell.cardBackground.isHidden = true
        cell.backgroundColor = .white
        cell.cardForeground.isHidden = false
    }
    
    func flipDown(for cell: CollectionViewCell){
        cell.cardForeground.isHidden = true
        cell.cardBackground.isHidden = false
    }
    
    
    func animatedFlipRight(for cell: CollectionViewCell){ // core animation
        UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }
    
    func animatedFlipLeft(for cell: CollectionViewCell){
        UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    func cellsRowAndColomn() -> (cellInRow: Int, cellInColomn: Int){
        var cellInRow = Int(floor(sqrt(Double(numberOfCards))))
        while (numberOfCards % cellInRow != 0) {
            cellInRow -= 1
            if (cellInRow == 1) {
                break
            }
        }
        let cellInColomn = numberOfCards / cellInRow
        return (cellInRow, cellInColomn)
    }

    var numberOfPairsOfCards: Int{    // init number of cards
        return (numberOfCards+1) / 2
    }
    
    let game = Functionallity()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishGameSegue"{
            let finish = segue.destination as! MenuPopupViewController
            _ = finish.view // forces to viewDidLoad 
            finish.finishedScore.text = "Your score: \(scores)" // found nil urwraping optional
            stopTimer()
            finish.finishedTime.text = "Time: "+String(format: "%.1f",counter)
            game.finishedLevels+=1
            finish.levelCompleted.text = "Level \(game.finishedLevels) completed"
        }
        if segue.identifier == "pauseGameSegue" {
            stopTimer()
        }
    }
    
    func stopTimer(){
        timer.invalidate()
        isRuning = false
    }
}

extension CardCollectionViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width
        let screenHeight = collectionView.frame.height
        let cell = cellsRowAndColomn()
        return CGSize(width: screenWidth/CGFloat(cell.cellInRow) - 10, height: screenHeight/CGFloat(cell.cellInColomn) - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        DispatchQueue.global().async {
            
            let foregroundPic = try! UIImage(withContentsOfUrl: self.selectedImages[indexPath.row].link)
            DispatchQueue.main.async {
                cell.cardForeground.image = foregroundPic
                self.index+=1
            }
        }
        cell.name = self.selectedImages[indexPath.row].name
        cell.cardForeground.isHidden = true
        cell.cardBackground.image = UIImage(named: "cardBack2")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        startTime() //starting timer
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        flippedCardsCount+=1 // first card flipped
        switch flippedCardsCount {
        case 1: // flips over one card with animation, setting first selected card to firstCard variable
            flipUp(for: cell)
            animatedFlipRight(for: cell)
            firstCard = indexPath
        case 2: // flips over second card
            let firstCell = collectionView.cellForItem(at: firstCard) as! CollectionViewCell
            if !(firstCell == cell){ // flips over second card with animation
                flipUp(for: cell)
                self.animatedFlipRight(for: cell)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: { // waiting for completion of animation, then checking if its match
                    if firstCell.name == cell.name {
                        firstCell.isHidden = true
                        cell.isHidden = true
                        self.numberOfCards-=2
                        self.scores+=10
                        if self.numberOfCards == 0{ //ends game when all cards are hidden
                            self.performSegue(withIdentifier: "finishGameSegue", sender: self)
                        }
                    }else{ //cards didnt matched, flip them down, score -2
                        self.flipDown(for: firstCell)
                        self.flipDown(for: cell)
                        self.scores-=2
                    }
                    self.animatedFlipLeft(for: firstCell) // animation for cells
                    self.animatedFlipLeft(for: cell)
                })
            }else{ // if user clicked on the same card do nothing, seting that one card is flipped
                flippedCardsCount = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: { // waiting for animation completion , then setting 0 flipped cards , game continues
                self.flippedCardsCount = 0
            })
        default: // if user tries immediately flip 3 card , do nothing
            print("wait")
            
        }
    }
}
