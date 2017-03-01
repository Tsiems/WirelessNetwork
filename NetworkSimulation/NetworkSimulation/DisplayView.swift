//
//  DisplayView.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/28/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit


class DisplayView: UIView {
    
    var NODE_SIZE:Double = 5.0
    var EDGE_WIDTH:Double = 1.0
    
    var nodes:[Node] = []
    var edges:[Edge] = []
    
    
    override func draw(_ rect: CGRect)
    {
        //draw nodes
        for node in nodes {
            drawNode(obj: node)
        }
        
        //draw edges
        for edge in edges {
            drawEdge(obj: edge)
        }
    }
    
    func drawNode(obj:Node) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(obj.color.cgColor)
        ctx?.setStrokeColor(obj.color.cgColor)
        ctx?.setLineWidth(CGFloat(NODE_SIZE))
        
        let rectangle = CGRect(x: obj.x-NODE_SIZE/2, y: obj.y-NODE_SIZE/2, width: NODE_SIZE, height: NODE_SIZE)
        ctx?.addEllipse(in: rectangle)
        ctx?.drawPath(using: .fillStroke)
    }
    
    func drawEdge(obj:Edge) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(EDGE_WIDTH))
        context?.setStrokeColor(obj.color.cgColor)
        context?.move(to: CGPoint(x: obj.node1.x, y: obj.node1.y))
        context?.addLine(to: CGPoint(x: obj.node2.x, y: obj.node2.y))
        context?.strokePath()
    }
}
