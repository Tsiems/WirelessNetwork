//
//  DisplayViewController.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/24/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

var CURRENT_NODES:[Node] = []
var CURRENT_EDGES:[Edge] = []
var CURRENT_CONNECTION_DISTANCE = 0.08
//var CURRENT_MODEL_INDEX:INT = 0

func getRandomDouble() -> Double {
    return Double(Float(arc4random()) / Float(UINT32_MAX))
}

func getRandomFloat() -> Float {
    return Float(arc4random()) / Float(UINT32_MAX)
}

class DisplayViewController: UIViewController {
    
    var networkModel = "Square"
    var nodeCount = 128 // will be changed by the slider
    var connectionDistance = 0.075
    var averageDegree = 6.0
    
    var shouldShowNodes = true
    var shouldShowEdges = true
    var shouldGenerateNewValues = true
    var node_size = 2.0
    var edge_width = 0.2
    
    var graphAdjList:[Int:[Node]] = [:]

    @IBOutlet weak var drawView: DisplayView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        var nodes:[Node] = [Node(x:50,y:100),Node(x:50,y:150),Node(x:100,y:100), Node(x:100,y:150)]
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = Double(screenSize.width)
        let screenHeight = Double(screenSize.height)
        
        
//        let nodes = generateRandomNodesOnRect(num: nodeCount, xMin: 50, yMin: 100, xMax: 50+squareEdgeSize, yMax: 100+squareEdgeSize)
        
        
        CURRENT_CONNECTION_DISTANCE = connectionDistance
        
        if shouldGenerateNewValues {
            if networkModel == "Disk" {
                let nodes = generateRandomNodesInDisk(num: nodeCount)
                CURRENT_NODES = nodes
            }
            else {
                let nodes = generateRandomNodesInSquare(num: nodeCount)
                CURRENT_NODES = nodes
            }
            let edges:[Edge] = generateEdgesBruteForce(nodes: CURRENT_NODES, r: connectionDistance)
            
            CURRENT_EDGES = edges
        }
        
        self.graphAdjList = getAdjacencyList(nodes: CURRENT_NODES, edges: CURRENT_EDGES)
        
        drawView.nodes = CURRENT_NODES
        drawView.edges = CURRENT_EDGES
        drawView.NODE_SIZE = self.node_size
        drawView.EDGE_WIDTH = self.edge_width
        drawView.shouldShowNodes = self.shouldShowNodes
        drawView.shouldShowEdges = self.shouldShowEdges
        
        
        drawView.model = networkModel
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        print("Going to menu")
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    func generateUniformNodes(num:Int,xMin:Double,yMin:Double,xMax:Double,yMax:Double) -> [Node]{
        var current_id = 0
        var nodes:[Node] = []
        let divider:Double = sqrt(Double(num))
        for i in 0 ..< num {
            
            // TODO: this only gets integers :(
            
            let x = xMin + Double( Int( Double(i) * xMax / divider) % Int( xMax ) )
            let y = yMin + yMax / divider * Double( Int( Double(i) * yMax / divider) / Int( yMax ) )
            let id = current_id
            
            current_id += 1
            nodes.append( Node(x:x,y:y,id:id ) )
        }
        
        return nodes
    }
    
    func generateRandomNodesOnRect(num:Int,xMin:Double,yMin:Double,xMax:Double,yMax:Double) -> [Node]{
        var nodes:[Node] = []
        var current_id = 0
        for _ in 0 ..< num {
            
            let x = xMin + (xMax-xMin) * getRandomDouble()
            let y = yMin + (yMax-yMin) * getRandomDouble()
            
            nodes.append( Node(x:x,y:y, id: current_id ) )
            current_id += 1
        }
        
        return nodes
    }
    
    func generateRandomNodesInSquare(num:Int) -> [Node]{
        var nodes:[Node] = []
        var current_id = 0
        for _ in 0 ..< num {
            let x = getRandomDouble()
            let y = getRandomDouble()
            nodes.append( Node(x:x,y:y, id: current_id ) )
            current_id += 1
        }
        return nodes
    }
    
    func generateRandomNodesInDisk(num:Int) -> [Node]{
        var nodes:[Node] = []
        var current_id = 0
        for _ in 0 ..< num {
            let r = sqrt(getRandomDouble())
            let degree = getRandomDouble()*360
            
            let x = r * cos(degree)
            let y = r * sin(degree)
            
            nodes.append( Node(x:x,y:y, id: current_id ) )
            current_id += 1
        }
        return nodes
    }
    
    
    func generateEdgesBruteForce(nodes:[Node], r:Double) -> [Edge] {
        // WARNING: this is very slow and is O(n^2)
        var edges:[Edge] = []
        
        for i in 0 ..< nodes.count-1 {
            for j in i+1 ..< nodes.count {
                if sqrt( pow(nodes[i].x-nodes[j].x,2) + pow(nodes[i].y-nodes[j].y,2)) <= r {
                    edges.append( Edge(node1: nodes[i],node2: nodes[j]))
                }
            }
        }
        
        return edges
    }


    func getAdjacencyList(nodes:[Node],edges:[Edge]) -> [Int:[Node]]{
        var adjList:[Int:[Node]] = [:]
        
        for node in nodes {
            adjList[node.id] = [node]
        }
        
        for edge in edges {
            adjList[edge.node1.id]?.append(edge.node2)
            adjList[edge.node2.id]?.append(edge.node1)
        }
        
//        print(adjList)
        
        return adjList
    }
    
    func colorGraph(adjList: [Int:[Node]]) {
        
        // TODO: Need to do real graph coloring
        var newNodes:[Node] = []
        for k in adjList.keys {
            adjList[k]?[0].color = UIColor(colorLiteralRed: getRandomFloat(), green: getRandomFloat(), blue: getRandomFloat(), alpha: 1.0)
//            print(adjList[k]?[0].color)
            newNodes.append((adjList[k]?[0])!)
        }
        drawView.nodes = newNodes
        drawView.setNeedsDisplay()
        
    }

    @IBAction func pressedColorGraphButton(_ sender: Any) {
        colorGraph(adjList: self.graphAdjList)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
