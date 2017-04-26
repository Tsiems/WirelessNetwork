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
    var z: Double = 0.0
//    var color: UIColor = UIColor.blue
    var color:Int = 0
    var id: Int = -1
    var countOfConnectedNodes = 0
    
    init(x:Double,y:Double,z:Double=0.0,id:Int,color:Int) {
        self.x = x
        self.y = y
        self.z = z
        self.id = id
        self.color = color
    }
    
    override var description: String {
        return "\(id)|(\(round(1000*x)/1000),\(round(1000*y)/1000))"
    }
}
