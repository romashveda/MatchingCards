//
//  NumberPickerViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/10/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit



class NumberPickerViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    let pickerArray = ["8","12","16","20"]
    
    let pickerSize: CGFloat = 60
    var amountOfCards = 0
    var temp: Int?
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectionButton: UIButton!

    @IBOutlet weak var start: UIButton!
    @IBAction func startGame(_ sender: UIButton) {
        amountOfCards = temp ?? 8
        performSegue(withIdentifier: "cardCollection", sender: self)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cardCollection" {
            let nav = segue.destination as! CardCollectionViewController
            nav.numberOfCards = amountOfCards
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: pickerSize, height: pickerSize))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerSize, height: pickerSize))
        label.text = pickerArray[row]
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40, weight: UIFont.Weight.bold)
        view.addSubview(label)
        
        return view
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerSize
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        temp = Int(pickerArray[row])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        self.picker.dataSource = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "retryGame"), object: nil, queue: OperationQueue.main)
        { (notification) in
            self.startGame(self.start)
        }
        
    }
    
    

}
