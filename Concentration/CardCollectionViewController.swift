//
//  ViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/3/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class CardCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    lazy var game = Concentration(numberOfPairsCards: numberOfPairsOfCards)
    
    @IBOutlet weak var cardsCollection: UICollectionView!
    @IBOutlet private weak var flipCountLabel: UILabel!
    
    var numberOfCards = 0
    
    var items = ["😎","🎃","👻","😈","😂","👹","😡","🙏","💂🏻‍♀️","🎅🏻","👠","⛑","🎒","🎩","🐹","🐸","🐼","🐵","🐣","🐢",
                 "🐡","🐙","🐍","🌲","🌴","🌏","🌹","🍎","🍋","🍓"]
    
    var emoji = [Int:String]()
    
    private func getEmoji(){
        for index in game.cards.indices{
            let randomInt = (items.count - 1).arc4random
            let card = game.cards[index]
            emoji[card.identifier] = items.remove(at: randomInt)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let card = game.cards[indexPath.item]
        cell.id = card.identifier
        cell.cardLabel.text = emoji[card.identifier]
        cell.cardLabel.isHidden = true
        cell.backgroundColor = .orange
        return cell
    }
    
    var flippedCardsCount = 0
    var firstCard: IndexPath = []
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        flippedCardsCount+=1
        switch flippedCardsCount {
        case 1:
            cell.backgroundColor = .white
            cell.cardLabel.isHidden = false
            animatedFlipRight(for: cell)
            firstCard = indexPath
            flipCount+=1
        case 2:
            flippedCardsCount-=2
            let firstCell = collectionView.cellForItem(at: firstCard) as! CollectionViewCell
            if !(firstCell == cell){
                cell.backgroundColor = .white
                cell.cardLabel.isHidden = false
                self.animatedFlipRight(for: cell)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if firstCell.cardLabel.text ?? "?" == cell.cardLabel.text ?? "?"{
                    firstCell.isHidden = true
                    cell.isHidden = true
                }else{
                    firstCell.cardLabel.isHidden = true
                    firstCell.backgroundColor = .orange
                    cell.cardLabel.isHidden = true
                    cell.backgroundColor = .orange
                }
                    self.animatedFlipLeft(for: firstCell)
                    self.animatedFlipLeft(for: cell)
                })
                flipCount+=1
            }else{
                flippedCardsCount+=1
            }
        default:
            print("smth wrong")
        }
    }
    func animatedFlipRight(for cell: CollectionViewCell){
        UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }
    
    func animatedFlipLeft(for cell: CollectionViewCell){
//        self.cardsCollection.isUserInteractionEnabled = false
        UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil
//            {
//            isFinished in self.cardsCollection.isUserInteractionEnabled = true
//            }
        )
    }
    
    //  Use for size
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let myWidth = cardsCollection.frame.width/4
//        let myHeight = cardsCollection.frame.height/5
//        let size = CGSize(width: myWidth, height: myHeight)
//        return size
//
//    }
//    //hotizontal
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 5.0
//    }
//
//    //  vertical
//    func collectionView(collectionView: UICollectionView, layout
//        collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 5.0
//    }
    
    
    var numberOfPairsOfCards: Int{
        return (numberOfCards+1) / 2
    }

    private(set) var flipCount = 0{
        didSet{
            flipCountLabel.text = "Flips: \(flipCount)"
        }
    }
    
    override func viewDidLoad() {
        getEmoji()
        super.viewDidLoad()
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

