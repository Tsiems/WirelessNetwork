//
//  SphereScene.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 4/13/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit
import SceneKit

extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2], count: 2)
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
}

class SphereScene: SCNScene {
    var nodes:[Node] = []
    var edges:[Edge] = []
    var extremeDegreeEdges:[Edge] = []
    var vectors:[Int:SCNVector3] = [:]
    
    override init() {
        super.init()
        basicSphere()
    }
    
    init(nodes:[Node]) {
        super.init()
        self.nodes = nodes
        displayNodesOnSphere(nodes: self.nodes)
    }
    
    init(nodes:[Node],edges:[Edge],extremeEdges:[Edge],shouldShowNodes:Bool=true,shouldShowEdges:Bool=false,shouldShowExtremeEdges:Bool=false) {
        super.init()
        
        self.nodes = nodes
        self.edges = edges
        self.extremeDegreeEdges = extremeEdges
        if shouldShowNodes {
            displayNodesOnSphere(nodes: self.nodes)
        }
        if shouldShowEdges {
            displayEdgesOnSphere(edges: self.edges)
            if shouldShowExtremeEdges {
                displayEdgesOnSphereWithColor(edges: extremeDegreeEdges)
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayEdgesOnSphere(edges:[Edge]) {
        for e in edges {
            if vectors[e.node1.id] == nil{
                vectors[e.node1.id] = SCNVector3(x: Float(e.node1.x), y: Float(e.node1.y), z: Float(e.node1.z))
            }
            if vectors[e.node2.id] == nil {
                vectors[e.node2.id] = SCNVector3(x: Float(e.node2.x), y: Float(e.node2.y), z: Float(e.node2.z))
            }
            let geometry = SCNGeometry.lineFrom(vector: vectors[e.node1.id]!, toVector: vectors[e.node2.id]!)
            let node = SCNNode(geometry: geometry)
            self.rootNode.addChildNode(node)
        }
    }
    
    func displayEdgesOnSphereWithColor(edges:[Edge]) {
        for e in edges {
            if vectors[e.node1.id] == nil{
                vectors[e.node1.id] = SCNVector3(x: Float(e.node1.x), y: Float(e.node1.y), z: Float(e.node1.z))
            }
            if vectors[e.node2.id] == nil {
                vectors[e.node2.id] = SCNVector3(x: Float(e.node2.x), y: Float(e.node2.y), z: Float(e.node2.z))
            }
            let geometry = SCNGeometry.lineFrom(vector: vectors[e.node1.id]!, toVector: vectors[e.node2.id]!)
            geometry.firstMaterial?.diffuse.contents = UIColor.red
            let node = SCNNode(geometry: geometry)
            self.rootNode.addChildNode(node)
        }
    }
    
    func displayNodesOnSphere(nodes:[Node]) {
        let radius:CGFloat = 0.01
        for n in nodes {
            let sphereGeometry = SCNSphere(radius: radius)
            sphereGeometry.segmentCount = 4
            sphereGeometry.firstMaterial?.diffuse.contents = COLOR_VALUES[n.color]
            let sphereNode = SCNNode(geometry: sphereGeometry)
            
            vectors[n.id] = SCNVector3(x: Float(n.x), y: Float(n.y), z: Float(n.z))
            
            sphereNode.position = vectors[n.id]!
            
            self.rootNode.addChildNode(sphereNode.flattenedClone())
        }
    }
    
    func basicSphere() {
        let sphereGeometry = SCNSphere(radius: 1.0)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        self.rootNode.addChildNode(sphereNode)
    }
    

}
