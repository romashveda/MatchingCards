//
//  Functionallity.swift
//  Concentration
//
//  Created by Roman Shveda on 2/6/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import Foundation
import UIKit

class Functionallity{
    var finishedLevels = 0
}


extension Int{ // random Int var
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

extension UIImage {
    convenience init? (withContentsOfUrl url: URL) throws{
        let imageData = try Data(contentsOf: url)
        self.init(data: imageData)
        
    }
}
