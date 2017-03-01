//
//  Edge.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/28/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

class Edge: NSObject {
    var node1:Node
    var node2:Node
    var color: UIColor = UIColor.red
    
    init(node1:Node,node2:Node,color:UIColor = UIColor.red) {
        self.node1 = node1
        self.node2 = node2
        self.color = color
    }
}
