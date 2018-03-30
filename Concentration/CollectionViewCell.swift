//
//  CollectionViewCell.swift
//  Concentration
//
//  Created by Roman Shveda on 1/11/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var cardBackground: UIImageView!
    @IBOutlet weak var cardForeground: UIImageView!
    var name: String = ""
}
