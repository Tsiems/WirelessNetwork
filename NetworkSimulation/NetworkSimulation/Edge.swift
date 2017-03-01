//
//  Edge.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/28/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

class Edge: NSObject {
    var x1: Double = 0.0
    var y1: Double = 0.0
    var x2: Double = 0.0
    var y2: Double = 0.0
    var color: UIColor = UIColor.red
    
    init(x1:Double,y1:Double,x2:Double,y2:Double,color:UIColor = UIColor.red) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.color = color
    }
}
