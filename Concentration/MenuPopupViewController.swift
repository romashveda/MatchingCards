//
//  FinishGamePopupViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/31/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import CoreData

class MenuPopupViewController: UIViewController {
    
    
    @IBOutlet weak var finishWindow: UIView!
    @IBOutlet weak var finishedScore: UILabel!
    @IBOutlet weak var finishedTime: UILabel!
    
    
    @IBAction func backToMenu(_ sender: UIButton) {
        let startMenu = self.storyboard?.instantiateViewController(withIdentifier: "MainMenu") as! NumberPickerViewController
        
        let startMenuNav = UINavigationController(rootViewController: startMenu)
        startMenuNav.isNavigationBarHidden = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = startMenuNav
        dismiss(animated: true, completion: nil)
//        navigationController?.popToRootViewController(animated: true)
    }
    // creates notification to restars the game
    @IBAction func retryButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "retryGame"), object: self)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func continueButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //початкова ініціалізація змінних, які ти передаєш з попереднього контролера (це можна організувати в segue
//    var level = 1
//    var time = 0.0
//    var score = 0
//    
//    var results: [NSManagedObject] = [] // це масив об’єктів кор дати
//    
//    // а тут ініціалізація самого звернення до бази данних
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Records") // назва твоєї схеми (Entity)
//        do {
//            results = try managedContext.fetch(fetchRequest)
//        } catch let err as NSError {
//            print("Failed to fetch items", err)
//        }
//        saveNewResult()
//    }
//    
//    func saveNewResult() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let context = appDelegate.persistentContainer.viewContext
//        let newResult = NSEntityDescription.insertNewObject(forEntityName: "Records", into: context) //знову назва твоєї схеми
//        newResult.setValue(level, forKey: "level") // тут жовтим атрибути в твоїй схемі
//        newResult.setValue(time, forKey: "time")
//        newResult.setValue(score, forKey: "score")
//        
//        do {
//            try context.save()
//            results.append(newResult)
//        } catch {
//            print("error")
//        }
//    }



}
