//
//  ViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/3/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class CardCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var timerLabel: UILabel!{
        didSet{
            timerLabel.text = "\(counter)"
        }
    }
    var timer = Timer()
    var counter = 0.0
    var isRuning = false
    
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
    
    @IBOutlet weak var cardsCollection: UICollectionView!
    @IBOutlet weak var score: UILabel!
    
    var numberOfCards = 0
    var scores = 0{
        didSet{
            score.text = "Score: \(scores)"
        }
    }
     // all posible emoji
    var items = ["😎","🎃","👻","😈","😂","👹","😡","🙏","💂🏻‍♀️","🎅🏻","👠","⛑","🎒","🎩","🐹","🐸","🐼","🐵","🐣","🐢",
                 "🐡","🐙","🐍","🌲","🌴","🌏","🌹","🍎","🍋","🍓"]
    //array of selected emojis for cells
    var emoji = [String]()
    // init  array of emojis whith two same values and shuffle this array , executes from viewDIdLoad
    private func getEmoji(){
        var unShuffled = [String]()
        for _ in 0..<numberOfPairsOfCards{
            let randomInt = (items.count - 1).arc4random
            let randomEmoji = items.remove(at: randomInt)
            unShuffled+=[randomEmoji,randomEmoji]
        }
        while !unShuffled.isEmpty{
            let randomIndex = unShuffled.count.arc4random
            emoji.append(unShuffled.remove(at: randomIndex))
            
        }
    }
    // creates number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards
    }
    var index = 0
    // cell initialization from emoji array by index, setting background
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.cardLabel.text = emoji[index]
        index+=1
        cell.cardLabel.isHidden = true
        cell.cardBackground.image = UIImage(named: "cardBack2")
        return cell
    }
    
    var flippedCardsCount = 0 // counts amount of already flipped cards
    var firstCard: IndexPath = [] // here will be indexpath of first flipped card
    var gameFinished = false // when true finishes game
    // logic for fliping and matching cards, works on click on cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        startTime()//starting timer
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        flippedCardsCount+=1 // first card flupped
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
                    if firstCell.cardLabel.text ?? "?" == cell.cardLabel.text ?? "?"{//if card match hide both
                        firstCell.isHidden = true
                        cell.isHidden = true
                        self.numberOfCards-=2
                        self.scores+=10 // add +10 to score if matches
                        if self.numberOfCards == 0{ //ends game when all card are hidden
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
    
//    func quickAnimation(for cell: CollectionViewCell){
//        UIView.transition(with: cell, duration: 0.2, options: .transitionFlipFromLeft, animations: nil, completion: nil)
//    }
    
    func flipUp(for cell: CollectionViewCell){
        cell.cardBackground.isHidden = true
        cell.backgroundColor = .white
        cell.cardLabel.isHidden = false
    }
    
    func flipDown(for cell: CollectionViewCell){
        cell.cardLabel.isHidden = true
        cell.cardBackground.isHidden = false
    }
    
    func animatedFlipRight(for cell: CollectionViewCell){
        UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }
    
    func animatedFlipLeft(for cell: CollectionViewCell){
        UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil
        )
    }
    
    //  Use for size
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width
        let screenHeight = collectionView.frame.height
        let cell = cellsRowAndColomn()
        return CGSize(width: screenWidth/CGFloat(cell.cellInRow) - 10, height: screenHeight/CGFloat(cell.cellInColomn) - 10)
    }
    
    // init number of cards
    var numberOfPairsOfCards: Int{
        return (numberOfCards+1) / 2
    }
    
    override func viewDidLoad() {
        getEmoji()
        super.viewDidLoad()
    }
    // direct to next controller , passing data to popUpView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishGameSegue"{
            let finish = segue.destination as! MenuPopupViewController
            _ = finish.view // forces to viewDidLoad 
            finish.finishedScore.text = "Your score: \(scores)"
            stopTimer()
            finish.finishedTime.text = "Time: "+String(format: "%.1f",counter)
//            finish.score = scores
//            finish.time = counter
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
// random Int var
extension Int{
    var arc4random: Int {
        switch self {
            case 1...Int.max:
                return Int(arc4random_uniform(UInt32(self)))
            case -Int.max..<0:
                return Int(arc4random_uniform(UInt32(self)))
            default:
                return 0
        }
    }
}

