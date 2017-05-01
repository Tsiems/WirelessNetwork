//
//  DisplayView.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/28/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

var COLOR_VALUES:[UIColor] = [UIColor(colorLiteralRed: getRandomFloat(), green: getRandomFloat(), blue: getRandomFloat(), alpha: 1.0)]

func generateColorValues() {
    COLOR_VALUES = []
    for _ in 0 ..< COLORS.count {
        COLOR_VALUES.append(UIColor(colorLiteralRed: getRandomFloat(), green: getRandomFloat(), blue: getRandomFloat(), alpha: 1.0))
    }
}

class DisplayView: UIView {
    
    var NODE_SIZE:Double = 5.0
    var EDGE_WIDTH:Double = 0.3
    
    var nodes:[Node] = []
    var edges:[Edge] = []
    var extremeDegreeEdges:[Edge] = []
    
    var shouldShowNodes = true
    var shouldShowEdges = true
    var shouldShowExtremeEdges = true
    
    var xMin:Double = 50
    var yMin:Double = 100
    var xMax:Double = 250
    var yMax:Double = 300
    
    var model = "Square"
    
    override func draw(_ rect: CGRect)
    {
        xMax = Double(rect.size.width)
        yMax = Double(rect.size.height)
        
        //draw nodes
        if shouldShowNodes {
            if model == "Square" || model == "Disk"{
                for node in nodes {
                    drawNodeInSquare(obj: node)
                }
            }
        }
        
        //draw edges
        if shouldShowEdges {
            if model == "Square" || model == "Disk" {
                for edge in edges {
                    drawEdgeInSquare(obj: edge)
                }
                
                if shouldShowExtremeEdges {
                    for edge in extremeDegreeEdges {
                        drawEdgeInSquare(obj: edge)
                    }
                }
            }
        }
    }
    
    func drawNodeInSquare(obj:Node) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(COLOR_VALUES[obj.color].cgColor)
        ctx?.setStrokeColor(COLOR_VALUES[obj.color].cgColor)
        ctx?.setLineWidth(CGFloat(NODE_SIZE))
        
        let rectangle = CGRect(x: xMax*obj.x-NODE_SIZE/2, y: yMax*obj.y-NODE_SIZE/2, width: NODE_SIZE, height: NODE_SIZE)
        ctx?.addEllipse(in: rectangle)
        ctx?.drawPath(using: .fillStroke)
    }
    
    func drawEdgeInSquare(obj:Edge) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(EDGE_WIDTH*2))
        context?.setLineWidth(CGFloat(EDGE_WIDTH))
        context?.setStrokeColor(obj.color.cgColor)
        context?.move(to: CGPoint(x: xMax*obj.node1.x, y: yMax*obj.node1.y))
        context?.addLine(to: CGPoint(x: xMax*obj.node2.x, y: yMax*obj.node2.y))
        context?.strokePath()
    }
}
