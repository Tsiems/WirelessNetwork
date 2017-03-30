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
    var EDGE_WIDTH:Double = 0.3
    
    var nodes:[Node] = []
    var edges:[Edge] = []
    
    var shouldShowNodes = true
    var shouldShowEdges = true
    
    var xMin:Double = 50
    var yMin:Double = 100
    var xMax:Double = 250
    var yMax:Double = 300
    
    var model = "Square"
    
    var xCenter:Double = 150
    var yCenter:Double = 200
    var radius:Double = 100
    
    
    
    
    override func draw(_ rect: CGRect)
    {
        print(rect)
        xMax = Double(rect.size.width)
        yMax = Double(rect.size.height)
        
        radius = Double(rect.size.height/2)
        xCenter = Double(rect.size.width/2)
        yCenter = Double(rect.size.height/2)
        
        //draw nodes
        if shouldShowNodes {
            
            if model == "Square" {
                for node in nodes {
                    drawNodeInSquare(obj: node)
                }
            }
            else if model == "Disk" {
//                var center = {x:y
                for node in nodes {
                    drawNodeInDisk(obj: node)
                }
            }
        }
        
        //draw edges
        if shouldShowEdges {
            if model == "Square" {
                for edge in edges {
                    drawEdgeInSquare(obj: edge)
                }
            }
            if model == "Disk" {
                for edge in edges {
                    drawEdgeInDisk(obj: edge)
                }
            }
        }
    }
    
    func drawNodeInSquare(obj:Node) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(obj.color.cgColor)
        ctx?.setStrokeColor(obj.color.cgColor)
        ctx?.setLineWidth(CGFloat(NODE_SIZE))
        print(obj.color)
        
        let rectangle = CGRect(x: xMax*obj.x-NODE_SIZE/2, y: yMax*obj.y-NODE_SIZE/2, width: NODE_SIZE, height: NODE_SIZE)
        ctx?.addEllipse(in: rectangle)
        ctx?.drawPath(using: .fillStroke)
    }
    
    func drawNodeInDisk(obj:Node) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(obj.color.cgColor)
        ctx?.setStrokeColor(obj.color.cgColor)
        ctx?.setLineWidth(CGFloat(NODE_SIZE))
        
        let rectangle = CGRect(x: xCenter+radius*obj.x-NODE_SIZE/2, y: yCenter+radius*obj.y-NODE_SIZE/2, width: NODE_SIZE, height: NODE_SIZE)
        ctx?.addEllipse(in: rectangle)
        ctx?.drawPath(using: .fillStroke)
    }
    
    
    func drawEdgeInSquare(obj:Edge) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(EDGE_WIDTH))
        context?.setStrokeColor(obj.color.cgColor)
        context?.move(to: CGPoint(x: xMax*obj.node1.x, y: yMax*obj.node1.y))
        context?.addLine(to: CGPoint(x: xMax*obj.node2.x, y: yMax*obj.node2.y))
        context?.strokePath()
    }
    func drawEdgeInDisk(obj:Edge) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(EDGE_WIDTH))
        context?.setStrokeColor(obj.color.cgColor)
        context?.move(to: CGPoint(x: xCenter+radius*obj.node1.x, y: yCenter+radius*obj.node1.y))
        context?.addLine(to: CGPoint(x: xCenter+radius*obj.node2.x, y: yCenter+radius*obj.node2.y))
        context?.strokePath()
    }
}
