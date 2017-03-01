//
//  Node.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/28/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

class Node: NSObject {
    var x: Double = 0.0
    var y: Double = 0.0
    var color: UIColor = UIColor.blue
    
    init(x:Double,y:Double,color:UIColor = UIColor.blue) {
        self.x = x
        self.y = y
        self.color = color
    }
}
