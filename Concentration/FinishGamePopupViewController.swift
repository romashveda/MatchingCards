//
//  FinishGamePopupViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/31/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class FinishGamePopupViewController: UIViewController {
    
    
    @IBOutlet weak var finishWindow: UIView!
    @IBOutlet weak var finishedScore: UILabel!
    @IBOutlet weak var finishedTime: UILabel!
    
    @IBAction func backToMenu(_ sender: UIButton) {
        let startMenu = self.storyboard?.instantiateViewController(withIdentifier: "MainMenu") as! NumberPickerViewController
        
        let startMenuNav = UINavigationController(rootViewController: startMenu)
//        startMenuNav.isNavigationBarHidden = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = startMenuNav
        dismiss(animated: true, completion: nil)
//        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func retryButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "retryGame"), object: self)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

}
