//
//  NumberPickerViewController.swift
//  Concentration
//
//  Created by Roman Shveda on 1/10/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit
import Reachability


class NumberPickerViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //array of possible card numbers

    let pickerArray = [8,12,16,20,24,28,32,36,40,44]
    let jsonArray = ["https://raw.githubusercontent.com/romashveda/Images/master/Nature/NatureImages.json","https://raw.githubusercontent.com/romashveda/Images/master/Sports/SportsImages.json","https://raw.githubusercontent.com/romashveda/Images/master/Social/SocialImages.json"]
    let pickerHeight: CGFloat = 60
    let pickerWidth: CGFloat = 100
    var temp = 8
    var images = [Image]()
    var rotationAngle: CGFloat!
    var imagesPick = [("Nature", #imageLiteral(resourceName: "natureImage")), ("Sports", #imageLiteral(resourceName: "sportsImage")), ("Social", #imageLiteral(resourceName: "socialImage"))]
    let group = DispatchGroup()
    let reachability = Reachability()!
    var reachable = false
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var picturePicker: UIPickerView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    
    
    
    @IBAction func startGame(_ sender: UIButton) {
        group.notify(queue: .main) {
            if self.reachable{
                self.performSegue(withIdentifier: "cardCollection", sender: self)
            } else {
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rotationAngle = -90 * (.pi/180)
        let y = picturePicker.frame.origin.y
        picturePicker.transform = CGAffineTransform(rotationAngle: rotationAngle)
        picturePicker.frame = CGRect(x: -100, y: y, width: view.frame.width, height: 300)
        leftArrow.image = UIImage(named: "leftArrow")
        rightArrow.image = UIImage(named: "rightArrow")
        leftArrow.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            reachable = true
        case .cellular:
            print("Reachable via Cellular")
            reachable = true
        case .none:
            print("Network not reachable")
            showAlert()
            reachable = false
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Network not reachable", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert,animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseJson(from: jsonArray[0])
        picker.delegate = self
        picker.dataSource = self
        picturePicker.delegate = self
        picturePicker.dataSource = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "retryGame"), object: nil, queue: OperationQueue.main) { notification in
            self.startGame(self.start)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "nextLevel"), object: nil, queue: OperationQueue.main) { notification in
            let level = notification.userInfo!["number"] as! Int
            self.temp = level + 4
            self.startGame(self.start)
        }
    }
    
    func parseJson(from link: String) {
        group.enter()
        let urlString = link
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
                        self.group.leave()
                    } catch {
                        print("Error")
                    }
                }.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cardCollection" {
            let nav = segue.destination as! CardCollectionViewController
            nav.numberOfCards = temp
            nav.images = images
        }
    }
}

extension NumberPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker{
            return pickerArray.count
        }else {
            return jsonArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == picker{
            pickerView.backgroundColor = UIColor.clear
            let view = UIView(frame: CGRect(x: 0, y: 0, width: pickerWidth, height: pickerHeight))
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerWidth, height: pickerHeight))
            label.text = "Level \((pickerArray.index(of: pickerArray[row]) ?? 1)+1)"
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.bold)
            view.addSubview(label)
            return view
        }
        else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            view.transform = CGAffineTransform(rotationAngle: -rotationAngle)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            picturePicker.backgroundColor = .clear
            image.image = imagesPick[row].1
            label.text = imagesPick[row].0
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.bold)
            view.addSubview(image)
            view.addSubview(label)
            return view
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView == picker {
            return pickerHeight
        }else {
            return 200
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == picker {
            temp = pickerArray[row]
        }else {
            parseJson(from: jsonArray[row])
            if row == 0 {
                leftArrow.isHidden = true
                rightArrow.isHidden = false
            }else {
                if row == 2{
                    rightArrow.isHidden = true
                }else {
                    rightArrow.isHidden = false
                }
                leftArrow.isHidden = false
            }
            
        }
    }
}
