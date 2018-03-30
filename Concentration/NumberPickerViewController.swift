//
//  NumberPickerViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/10/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit



class NumberPickerViewController: UIViewController {
    //array of possible card numbers

//    let pickerArray = [8]
    let pickerArray = [8,12,16,20,24,28,32,36,40]
    let pickerHeight: CGFloat = 60
    let pickerWidth: CGFloat = 100
    var temp: Int?
    var images = [Image]()
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var start: UIButton!
    
    @IBAction func startGame(_ sender: UIButton) {
        performSegue(withIdentifier: "cardCollection", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "retryGame"), object: nil, queue: OperationQueue.main) { notification in
            self.startGame(self.start)
        }
        jsonParser()
    }
    
    func jsonParser() {
        let urlString = "https://raw.githubusercontent.com/romashveda/Images/master/Nature/NatureImages.json"
        guard let url = URL(string: urlString) else {
            print("url not valid")
            return}
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            URLSession.shared.dataTask(with: url) { (data, responce, error) in
                guard let data = data else {return}
                guard error == nil else {return}
                    do {
                        let images = try JSONDecoder().decode([Image].self, from: data)
                        self.images = images
                    } catch {
                        print("Error")
                    }
                }.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cardCollection" {
            let nav = segue.destination as! CardCollectionViewController
            nav.numberOfCards = temp ?? 8
            nav.images = images
        }
    }
}

extension NumberPickerViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }

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

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        temp = pickerArray[row]
    }
    
}
