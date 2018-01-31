//
//  ViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/3/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class CardCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
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
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isRuning = true
        }
    }
    
    @objc func UpdateTimer(){
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
    
    var items = ["😎","🎃","👻","😈","😂","👹","😡","🙏","💂🏻‍♀️","🎅🏻","👠","⛑","🎒","🎩","🐹","🐸","🐼","🐵","🐣","🐢",
                 "🐡","🐙","🐍","🌲","🌴","🌏","🌹","🍎","🍋","🍓"]
    
    var emoji = [String]()
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards
    }
    var index = 0
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.cardLabel.text = emoji[index]
        index+=1
        cell.cardLabel.isHidden = true
        cell.cardBackground.image = UIImage(named: "cardBackground")
        return cell
    }
    
    var flippedCardsCount = 0
    var firstCard: IndexPath = []
    var gameFinished = false
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        startTime()
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        flippedCardsCount+=1
        switch flippedCardsCount {
        case 1:
            flipUp(for: cell)
            animatedFlipRight(for: cell)
            firstCard = indexPath
        case 2:
            let firstCell = collectionView.cellForItem(at: firstCard) as! CollectionViewCell
            if !(firstCell == cell){
                flipUp(for: cell)
                self.animatedFlipRight(for: cell)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if firstCell.cardLabel.text ?? "?" == cell.cardLabel.text ?? "?"{
                    firstCell.isHidden = true
                    cell.isHidden = true
                    self.numberOfCards-=2
                    self.scores+=10
                    if self.numberOfCards == 0{
                        self.performSegue(withIdentifier: "finishGameSegue", sender: self)
                    }
                }else{
                    self.flipDown(for: firstCell)
                    self.flipDown(for: cell)
                    self.scores-=2
                }
                    self.animatedFlipLeft(for: firstCell)
                    self.animatedFlipLeft(for: cell)
                })
            }else{
                flippedCardsCount = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.flippedCardsCount = 0
            })
        default:
            print("wait")
        }
    }
    
    func quickAnimation(for cell: CollectionViewCell){
        UIView.transition(with: cell, duration: 0.2, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
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
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let myWidth = cardsCollection.frame.width/4
        let myHeight = cardsCollection.frame.height/5
        let size = CGSize(width: myWidth, height: myHeight)
        return size

    }

    var numberOfPairsOfCards: Int{
        return (numberOfCards+1) / 2
    }
    
    override func viewDidLoad() {
        getEmoji()
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishGameSegue"{
            let finish = segue.destination as! FinishGamePopupViewController
            _ = finish.view // forces to viewDidLoad 
            finish.finishedScore.text = "Your score: \(scores)"
            timer.invalidate()
            finish.finishedTime.text = "Time: "+String(format: "%.1f",counter)
        }
    }

}
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

