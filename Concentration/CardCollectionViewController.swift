//
//  ViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/3/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import CoreData

class CardCollectionViewController: UIViewController{
    
    let group = DispatchGroup()
    var timer = Timer()
    var counter = 0.0
    var isRuning = false
    var flippedCardsCount = 0 // counts amount of already flipped cards
    var firstCard: IndexPath = [] // here will be indexpath of first flipped card
    var index = 0
    var numberOfCards = 0
    var results: [NSManagedObject] = []
    
    var scores = 0 {
        didSet{
            score.text = "Score: \(scores)"
        }
    }
    var cardLevel = 0
    var images = [Image]()
    var selectedImages = [Image]()
    var dowloadedImages = [URL:UIImage]()
    
    @IBOutlet weak var cardsCollection: UICollectionView!
    @IBOutlet weak var score: UILabel!
    @IBOutlet var fininshPopup: UIView!
    @IBOutlet var pausePopup: UIView!
    @IBOutlet weak var pauseButt: UIButton!
    @IBOutlet weak var yourScore: UILabel!
    @IBOutlet weak var highScore: UILabel!
    
    @IBAction func pauseButt(_ sender: UIButton) {
        addPopUp(viewTo: pausePopup)
    }
    
    @IBAction func toMenu(_ sender: UIButton) {
        let startMenu = self.storyboard?.instantiateViewController(withIdentifier: "MainMenu") as! NumberPickerViewController
        let startMenuNav = UINavigationController(rootViewController: startMenu)
        startMenuNav.isNavigationBarHidden = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = startMenuNav
        dismiss()
    }
    @IBAction func resetButt(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "retryGame"), object: self)
        dismiss()
    }
    @IBAction func dissmisPopup(_ sender: Any) {
        dismiss()
    }
    @IBAction func toNextLevel(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "nextLevel"), object: self, userInfo: ["number": cardLevel])
        dismiss()
    }
    
    func dismiss(){
        UIView.animate(withDuration: 0.3, animations: {
            self.pausePopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.pausePopup.alpha = 0
        }) { (success) in
            self.pausePopup.removeFromSuperview()
        }
        self.cardsCollection.isUserInteractionEnabled = true
        self.pauseButt.isUserInteractionEnabled = true
    }
    
    func showFinishMenu(){
        checkResultsEmpty()
        addPopUp(viewTo: fininshPopup)
        yourScore.text = "Your score: \(scores) points, " + String(format: "%.1f",counter)+" s"
    }
    
    func addPopUp(viewTo: UIView) {
        self.cardsCollection.isUserInteractionEnabled = false
        self.pauseButt.isUserInteractionEnabled = false
        self.view.addSubview(viewTo)
        stopTimer()
        viewTo.center = self.view.center
        viewTo.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        viewTo.alpha = 0
        UIView.animate(withDuration: 0.4) {
            viewTo.alpha = 1
            viewTo.transform = CGAffineTransform.identity
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cardLevel = numberOfCards
        getImage()
        fetchResults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fininshPopup.layer.cornerRadius = 10
        pausePopup.layer.cornerRadius = 10
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
    
    func getImage() {
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

    var numberOfPairsOfCards: Int {    // init number of cards
        return (numberOfCards+1) / 2
    }
    
    let game = Functionallity()
    
    func stopTimer(){
        timer.invalidate()
        isRuning = false
    }
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    func startIndicator() {
        // Position Activity Indicator in the center of the main view
        activityIndicator.center = view.center
        // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
        activityIndicator.hidesWhenStopped = false
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func checkResultsEmpty() {
        var saved = false
        if results.isEmpty{
            saveNewResult()
        }else {
            for result in results {
                // Checking result by cardsNumber Key
                let cardsResult = result.value(forKey: "cardsNumber") as! Int
                if cardsResult == cardLevel {
                    saveBestRecordForLevel()
                    saved = true
                }
            }
            if !saved {
                saveNewResult()
            }
        }
    }
    
    func fetchResults() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Records")
        do {
            results = try managedContext.fetch(fetchRequest)
        } catch let err as NSError {
            print("Failed to fetch items", err)
        }
    }
    
    func saveNewResult() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let newResult = NSEntityDescription.insertNewObject(forEntityName: "Records", into: context)
        newResult.setValue(cardLevel, forKey: "cardsNumber")
        newResult.setValue(counter, forKey: "time")
        newResult.setValue(scores, forKey: "score")
        do {
            try context.save()
            results.append(newResult)
        } catch {
            print("error")
        }
    }
    
    func saveBestRecordForLevel() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        for result in results {
            let cardsResult = result.value(forKey: "cardsNumber") as! Int
            if cardsResult == cardLevel {
                let scoreResult = result.value(forKey: "score") as! Int
                let timeResult = result.value(forKey: "time") as! Double

                if scoreResult < scores || (scoreResult == scores && timeResult >= counter) {
                    result.setValue(scores, forKey: "score")
                    result.setValue(counter, forKey: "time")
                }
            }
        }
        do {
            try context.save()
        } catch {
            print("error")
        }

    }
    
    func printDataFromDB() {
        print("================= BEST RECORDS IN DATABASE =================")
        for result in results {
            let cardsResult = result.value(forKey: "cardsNumber") ?? 0
            let scoreResult = result.value(forKey: "score") ?? 0
            let timeResult = result.value(forKey: "time") ?? 0
            let time = timeResult as! Double
            print("CARDS : [\(cardsResult)] cards || SCORE : [\(scoreResult)] || TIME : [\(timeResult)] seconds")
            if cardsResult as! Int == cardLevel{
                highScore.text = "Highscore: \(scoreResult) points, " + String(format: "%.1f",time)+" s"
            }
        }
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
        let link = selectedImages[indexPath.row].link
        if let image = dowloadedImages[link] {
            cell.cardForeground.image = image
        } else {
        DispatchQueue.global().async { [weak self] in
            guard let weakSelf = self else {return}
            let foregroundPic = try! UIImage(withContentsOfUrl: weakSelf.selectedImages[indexPath.row].link)
            DispatchQueue.main.async { [weak self, weak cell] in
                guard let weakSelf = self else {return}
//                self?.group.enter()
//                weakSelf.startIndicator()
                weakSelf.dowloadedImages[link] = foregroundPic
                cell?.cardForeground.image = foregroundPic
//                self?.group.leave()
                weakSelf.index+=1
            }
        }
        }
        cell.name = self.selectedImages[indexPath.row].name
        cell.cardForeground.isHidden = true
        cell.cardBackground.image = UIImage(named: "cardBack2")
//        group.notify(queue: .main) {
//            self.stopIndicator()
//        }
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
                            self.checkResultsEmpty()
                            self.showFinishMenu()
                            self.printDataFromDB()
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
