//
//  NumberPickerViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/10/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit



class NumberPickerViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    //array of possible card numbers

    let pickerArray = [8,12,16,20,24,28,32,36,40]
    
    let pickerHeight: CGFloat = 60
    let pickerWidth: CGFloat = 100
    // temporary variable for getting information from picker
    var temp: Int?
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectionButton: UIButton!

    @IBOutlet weak var start: UIButton!
    
    @IBAction func startGame(_ sender: UIButton) {
        performSegue(withIdentifier: "cardCollection", sender: self)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cardCollection" {
            let nav = segue.destination as! CardCollectionViewController
            nav.numberOfCards = temp ?? 8
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    //custumizing picker
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: pickerWidth, height: pickerHeight))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerWidth, height: pickerHeight))
        label.text = "Level \((pickerArray.index(of: pickerArray[row]) ?? 1)+1)"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.bold)
        view.addSubview(label)
        return view
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerHeight
    }
    // initializing optional var temp from pickerarray and parsing to Int
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        temp = pickerArray[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        self.picker.dataSource = self
        // geting information from NotCenter that comands to start game again(retry)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "retryGame"), object: nil, queue: OperationQueue.main)
        { (notification) in
            self.startGame(self.start)
        }
        
    }
    
    

}
