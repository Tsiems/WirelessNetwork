//
//  DisplayViewController.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/24/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit
import SceneKit

var CURRENT_NODES:[Node] = []
var CURRENT_EDGES:[Edge] = []
var CURRENT_CONNECTION_DISTANCE = 0.08
var TIME_TO_CREATE_GRAPH = 0.0
var TIME_TO_COLOR_GRAPH = 0.0
var TIME_FOR_SMALLEST_LAST_ORDERING = 0.0
var TIME_FOR_BIPARTITE = 0.0
var CURRENT_ADJACENCY_LIST:[[Node]] = []
var CURRENT_COLORS_ASSIGNED:[Int] = []
var CURRENT_COLOR_FREQUENCIES:[Int:Int] = [:]
var CURRENT_COLOR_FREQUENCIES_PAIRED:[(Int,Int)] = []
var COLORS:[Int] = []
var DEGREE_WHEN_DELETED:[Int] = []
var ORIGINAL_DEGREE:[Int] = []
var TERMINAL_CLIQUE_SIZE = 1

let VERIFICATION_WALKTHROUGH = false


func getRandomDouble() -> Double {
    return Double(Float(arc4random()) / Float(UINT32_MAX))
}

func getRandomFloat() -> Float {
    return Float(arc4random()) / Float(UINT32_MAX)
}

class DisplayViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet weak var titleLabel: UILabel!
    
    var networkModel = "Square"
    var nodeCount = 128 // will be changed by the slider
    var connectionDistance = 0.075
    var averageDegree = 6.0
    
    var sphereNodes:[Node] = []
    var sphereEdges:[Edge] = []
    var extremeDegreeEdges:[Edge] = []
    
    var shouldShowNodes = true
    var shouldShowEdges = true
    var shouldGenerateNewValues = true
    var node_size = 2.0
    var edge_width = 0.2
    
    var colorStats:[(String,String)] = []
    var bipartiteStats:[(String,String)] = []
    
    var graphAdjList:[[Node]] = []

    @IBOutlet weak var sceneKitView: SCNView!
    @IBOutlet weak var drawView: DisplayView!
    @IBOutlet weak var showNodesSwitch: UISwitch!
    @IBOutlet weak var showEdgesSwitch: UISwitch!
    
    @IBOutlet weak var showBipartiteSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.title
        showNodesSwitch.isOn = shouldShowNodes
        showEdgesSwitch.isOn = shouldShowEdges
        
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        
        self.showBipartiteSwitch.isEnabled = color1 != color2 && color1 != -1 && color2 != -1
        
        
        CURRENT_CONNECTION_DISTANCE = connectionDistance
        TERMINAL_CLIQUE_SIZE = 1
        
        let startTime = Date()
        if shouldGenerateNewValues {
            if networkModel == "Disk" {
                let nodes = generateRandomNodesInDisk(num: nodeCount)
                CURRENT_NODES = nodes
                
                let edges:[Edge] = generateEdgesUsingCellMethod(nodes: CURRENT_NODES, r: connectionDistance)
                CURRENT_EDGES = edges
                
                self.drawView.isHidden = false
                self.sceneKitView.isHidden = true
                
            } else if networkModel == "Sphere" {
                let nodes = generateRandomNodesInSphere(num: nodeCount)
                CURRENT_NODES = nodes
                
                let edges = generateEdgesUsingCellMethod3d(nodes: CURRENT_NODES, r: connectionDistance)

                CURRENT_EDGES = edges
                
                sphereEdges = edges
                sphereNodes = nodes
            }
            else {
                let nodes = generateRandomNodesInSquare(num: nodeCount)
                CURRENT_NODES = nodes
                
                let edges:[Edge] = generateEdgesUsingCellMethod(nodes: CURRENT_NODES, r: connectionDistance)
                CURRENT_EDGES = edges
                
                
                self.drawView.isHidden = false
                self.sceneKitView.isHidden = true
            }
            
            
        }
        
        let graphCreatedTime = Date()
        
        TIME_TO_CREATE_GRAPH = graphCreatedTime.timeIntervalSince(startTime)
        
        self.graphAdjList = getAdjacencyList(nodes: CURRENT_NODES, edges: CURRENT_EDGES)
        CURRENT_ADJACENCY_LIST = self.graphAdjList
        
        if VERIFICATION_WALKTHROUGH {
            print("\nAdjacency List")
            for row in CURRENT_ADJACENCY_LIST {
                for item in row {
                    print(item.id,terminator:" -> ")
                }
                print("X")
            }
            print()
        }
        
        
        let minMaxDegreeIds = findMinAndMaxDegreeNodes()
        
        extremeDegreeEdges = []
        for e in CURRENT_EDGES {
            if e.node1.id == minMaxDegreeIds.0 || e.node2.id == minMaxDegreeIds.0 {
                let edge = e
                edge.color = UIColor.blue
                extremeDegreeEdges.append(edge)
            }
            else if e.node1.id == minMaxDegreeIds.1 || e.node2.id == minMaxDegreeIds.1 {
                let edge = e
                edge.color = UIColor.green
                extremeDegreeEdges.append(edge)
            }
        }
        
        
        
        if networkModel == "Sphere" {
            displaySphereNetwork()
            
        } else {
            drawView.nodes = CURRENT_NODES
            drawView.edges = CURRENT_EDGES
            drawView.NODE_SIZE = self.node_size
            drawView.EDGE_WIDTH = self.edge_width
            drawView.shouldShowNodes = self.shouldShowNodes
            drawView.shouldShowEdges = self.shouldShowEdges
            drawView.extremeDegreeEdges = extremeDegreeEdges
            drawView.model = networkModel
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        print("Going to menu")
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    func resetSphereNetwork() {
        self.sceneKitView.scene = SphereScene()
    }
    
    func displaySphereNetwork() {
        self.drawView.isHidden = true
        self.sceneKitView.isHidden = false
        
        self.sceneKitView.scene = SphereScene(nodes:sphereNodes,edges:sphereEdges,extremeEdges:extremeDegreeEdges,shouldShowNodes:shouldShowNodes,shouldShowEdges:shouldShowEdges,shouldShowExtremeEdges: !self.showBipartiteSwitch.isOn )
        
        self.sceneKitView.backgroundColor = UIColor.black
        self.sceneKitView.allowsCameraControl = CURRENT_NODES.count < 7000
    }
    
    
    func generateRandomNodesInSquare(num:Int) -> [Node]{
        var nodes:[Node] = []
        var current_id = 0
        for _ in 0 ..< num {
            let x = getRandomDouble()
            let y = getRandomDouble()
            let node = Node(x:x,y:y, id: current_id, color: 0 )
            
            nodes.append( node )
            current_id += 1
        }
        if VERIFICATION_WALKTHROUGH {
            for node in nodes {
                print(node)
            }
        }
        return nodes
    }
    
    func generateRandomNodesInDisk(num:Int) -> [Node]{
        var nodes:[Node] = []
        var current_id = 0
        for _ in 0 ..< num {
            let r = sqrt(getRandomDouble())
            let degree = getRandomDouble()*360
            
            let x = (r * cos(degree) + 1.0)/2.0
            let y = (r * sin(degree) + 1.0)/2.0
            let node = Node(x:x,y:y, id: current_id, color: 0 )
            nodes.append( node )
            current_id += 1
        }
        return nodes
    }
    
    func generateRandomNodesInSphere(num:Int) -> [Node]{
        var nodes:[Node] = []
        var current_id = 0
        for _ in 0 ..< num {
            let u = getRandomDouble()*2.0 - 1.0
            let degree = getRandomDouble()*360
            let x = sqrt(1 - u*u)*cos(degree)
            let y = sqrt(1 - u*u)*sin(degree)
            let z = u
            nodes.append( Node(x:x,y:y,z:z, id: current_id, color: 0 ) )
            current_id += 1
        }
        return nodes
    }
    
    
    func generateEdgesBruteForce(nodes:[Node], r:Double) -> [Edge] {
        // WARNING: this is very slow and is O(n^2)
        var edges:[Edge] = []
        
        for i in 0 ..< nodes.count-1 {
            for j in i+1 ..< nodes.count {
                if sqrt( pow(nodes[i].x-nodes[j].x,2) + pow(nodes[i].y-nodes[j].y,2) + pow(nodes[i].z-nodes[j].z,2)) <= r {
                    edges.append( Edge(node1: nodes[i],node2: nodes[j]))
                }
            }
        }
        print("Brute Force Edges: ",edges.count)
        
        return edges
    }
    
    func generateEdgesUsingCellMethod(nodes:[Node], r:Double) -> [Edge] {
        var edges:[Edge] = []
        
        let rowCount = Int(ceil(1.0/r))
        
        var cells:[[[Node]]] = [[[Node]]](repeating: [[Node]](repeating: [], count: rowCount ), count: rowCount)
        
        for node in nodes {
            cells[ Int(node.x/r) ][ Int(node.y/r) ].append(node)
        }
        
        //for each cell
        var i = 0
        while (i < rowCount) {
            var j = 0
            while (j < rowCount) {
                var testNodes:[Node] = []
                
                //find adjacent cells
                if i+1 < rowCount && j+1 < rowCount {
                    let firstHalf = cells[i+1][j]
                    let secondHalf = cells[i][j+1] + cells[i+1][j+1]
                    
                    testNodes.append(contentsOf:firstHalf + secondHalf)
                    
                    if j > 0 {
                        testNodes.append(contentsOf:cells[i+1][j-1])
                    }
                } else if i+1 < rowCount {
                    testNodes.append(contentsOf: cells[i+1][j])
                    
                    if j > 0 {
                        testNodes.append(contentsOf:cells[i+1][j-1])
                    }
                } else if j+1 < rowCount {
                    testNodes.append(contentsOf: cells[i][j+1])
                }
                

                // test nodes in adjacent cells
                for node in cells[i][j] {
                    var l = 0
                    while (l < testNodes.count) {
                        if sqrt( pow(node.x-testNodes[l].x,2) + pow(node.y-testNodes[l].y,2)) <= r {
                            edges.append( Edge(node1: node,node2: testNodes[l]))
                        }
                        l += 1
                    }
                }
                
                // test nodes within
                var k = 0
                while k < cells[i][j].count-1 {
                    var l = k+1
                    while l < cells[i][j].count {
                        if sqrt( pow(cells[i][j][k].x-cells[i][j][l].x,2) + pow(cells[i][j][k].y-cells[i][j][l].y,2)) <= r {
                            edges.append( Edge(node1: cells[i][j][k],node2: cells[i][j][l]))
                        }
                        l += 1
                    }
                    k += 1
                }
                j += 1
            }
            i += 1
        }
        
        print(edges.count)
        
        return edges
    }
    
    func generateEdgesUsingCellMethod3d(nodes:[Node], r:Double) -> [Edge] {
        var edges:[Edge] = []
        
        let rowCount = Int(ceil(2.0/r))
        
        var cells:[[[[Node]]]] = [[[[Node]]]](repeating: [[[Node]]](repeating: [[Node]](repeating: [], count: rowCount ), count: rowCount ), count: rowCount)
        
        for node in nodes {
            let i = Int((node.x+1.0)/r)
            let j = Int((node.y+1.0)/r)
            let k = Int((node.z+1.0)/r)
            cells[ i ][ j ][ k ].append(node)
        }
        
        let time2 = Date()
        
        //for each cell
        var i = 0
        while (i < rowCount) {
            var j = 0
            while (j < rowCount) {
                var k = 0
                while (k < rowCount) {
                    if cells[i][j][k].count > 0 {
                        var testNodes:[Node] = []
                        
                        //find adjacent cells
                        if i+1 < rowCount && j+1 < rowCount && k+1 < rowCount {
                            let one = cells[i][j][k+1]
                            let two = cells[i][j+1][k]
                            let three = cells[i][j+1][k+1]
                            let four = cells[i+1][j][k]
                            let five = cells[i+1][j][k+1]
                            let six = cells[i+1][j+1][k]
                            let seven = cells[i+1][j+1][k+1]
                            
                            testNodes.append(contentsOf: ((one+two)+(three+four))+((five+six)+seven))
                            
                            if j > 0 {
                                let eight = cells[i+1][j-1][k]
                                let nine = cells[i+1][j-1][k+1]
                                testNodes.append(contentsOf: eight+nine)
                            }
                        } else if i+1 < rowCount && j+1 < rowCount {
                            let two = cells[i][j+1][k]
                            let four = cells[i+1][j][k]
                            let six = cells[i+1][j+1][k]
                            
                            testNodes.append(contentsOf: (two+four)+six )
                            
                            if j > 0 {
                                let eight = cells[i+1][j-1][k]
                                testNodes.append(contentsOf: eight)
                            }
                            
                        } else if i+1 < rowCount && k+1 < rowCount {
                            let one = cells[i][j][k+1]
                            let four = cells[i+1][j][k]
                            let five = cells[i+1][j][k+1]
                            
                            testNodes.append(contentsOf: (one+four)+five )
                            
                            if j > 0 {
                                let eight = cells[i+1][j-1][k]
                                let nine = cells[i+1][j-1][k+1]
                                testNodes.append(contentsOf: eight+nine)
                            }
                        } else if i+1 < rowCount {
                            testNodes.append(contentsOf: cells[i+1][j][k])
                            
                            if j > 0 {
                                testNodes.append(contentsOf:cells[i+1][j-1][k])
                            }
                        } else if j+1 < rowCount && k+1 < rowCount {
                            let one = cells[i][j][k+1]
                            let two = cells[i][j+1][k]
                            let three = cells[i][j+1][k+1]
                            
                            testNodes.append(contentsOf: (one+two)+three )
                            
                        } else if j+1 < rowCount {
                            testNodes.append(contentsOf: cells[i][j+1][k])
                        } else if k+1 < rowCount {
                            testNodes.append(contentsOf: cells[i][j][k+1])
                        }
                        
                        
                        // test nodes in adjacent cells
                        for node in cells[i][j][k] {
                            var l = 0
                            while (l < testNodes.count) {
                                if sqrt( pow(node.x-testNodes[l].x,2) + pow(node.y-testNodes[l].y,2) + pow(node.z-testNodes[l].z,2)) <= r {
                                    edges.append( Edge(node1: node,node2: testNodes[l]))
                                }
                                l += 1
                            }
                        }
                        
                        // test nodes within
                        var m = 0
                        while m < cells[i][j][k].count-1 {
                            var l = m+1
                            while l < cells[i][j][k].count {
                                if sqrt( pow(cells[i][j][k][m].x-cells[i][j][k][l].x,2) + pow(cells[i][j][k][m].y-cells[i][j][k][l].y,2) + pow(cells[i][j][k][m].z-cells[i][j][k][l].z,2)) <= r {
                                    edges.append( Edge(node1: cells[i][j][k][m],node2: cells[i][j][k][l]))
                                }
                                l += 1
                            }
                            m += 1
                        }
                    }
                    k+=1
                }
                j += 1
            }
            i += 1
        }
        
        let time3 = Date()
        
        print("Time new: ",time3.timeIntervalSince(time2))
        
        print(edges.count)
        
        return edges
    }


    func getAdjacencyList(nodes:[Node],edges:[Edge]) -> [[Node]]{
        var adjList:[[Node]] = [[Node]](repeating: [], count: nodes.count)
        
        for node in nodes {
            adjList[node.id] = [node]
        }
        
        for edge in edges {
            adjList[edge.node1.id].append(edge.node2)
            adjList[edge.node2.id].append(edge.node1)
        }
        
        return adjList
    }
    
    
    func updateValueLocation(id:Int, sortedList: inout [(Int,Int)],  referenceList: inout [([Node],Int)]) {
        let testValue = sortedList[referenceList[id].1].1
        
        var i = referenceList[id].1
        
        let value = sortedList.remove(at: i)
        while i < sortedList.count {
            if sortedList[i].1 <= testValue {
                break
            }
            else {
                //update reference list
                referenceList[sortedList[i].0].1 = i
            }
            i += 1
        }
        sortedList.insert(value, at: i)
        referenceList[sortedList[i].0].1 = i
    }
    
    func subtractBucket(value:Int,buckets: inout [[Int]], referenceList: inout [([Int],Int)]) {
        
        //iterate through current value's bucket
        for (index,nodeId) in buckets[ referenceList[value].1 ].enumerated() {
            //find node
            if nodeId == value {
                //move node to lower bucket
                _ = buckets[ referenceList[value].1 ].remove(at: index)
                referenceList[value].1 -= 1
                buckets[ referenceList[value].1 ].append(value)
                break
            }
        }
    }
    
    func sortBySmallestLastDegreeFast(adjList: [[Node]], shouldPrint:Bool=false) -> [[Node]] {
        colorStats = []
        DEGREE_WHEN_DELETED = []
        ORIGINAL_DEGREE = []
        
        let startTimeFaster = Date()
        
        var newList:[[Node]] = []
        
        var buckets:[[Int]] = [[Int]](repeating: [], count: adjList.count-1)
        
        var referenceList:[([Int],Int)] = [([Int],Int)](repeating: ([],-1), count: adjList.count)
        
        var maxDegree = 0
        var totalDegree = 0
        TERMINAL_CLIQUE_SIZE = 1
        
        //put values in list
        for list in adjList {
            buckets[list.count-1].append(list[0].id)
            
            var newList = list.map({$0.id})
            newList.remove(at: 0)
            referenceList[list[0].id] = (newList,list.count-1)
            
            if list.count-1 > maxDegree {
                maxDegree = list.count-1
            }
            totalDegree += list.count-1
        }
        
        if shouldPrint {
            print(buckets)
        }
        
        let midTimeFaster = Date()
        var minIndex = 0
        while newList.count < adjList.count {
            while( buckets[minIndex].count == 0  ) {
                minIndex += 1
            }
            let min_bucket_size = buckets[minIndex].count
            let minVal = buckets[minIndex].popLast()!
            
            let number_left = adjList.count-newList.count
            if min_bucket_size == number_left && TERMINAL_CLIQUE_SIZE == 1 && minIndex+1 == min_bucket_size{
                
                TERMINAL_CLIQUE_SIZE = min_bucket_size
                if shouldPrint {
                    print(min_bucket_size,minIndex,newList.count,adjList.count)
                    print("Terminal Clique found: Size ",TERMINAL_CLIQUE_SIZE)
                }
            }
            
            
            newList.append(adjList[minVal])
            DEGREE_WHEN_DELETED.append(referenceList[minVal].1)
            
            referenceList[minVal].1 = -1
            
            let nodeList = referenceList[minVal].0
            ORIGINAL_DEGREE.append(nodeList.count)
            
            
            for id in nodeList {
                if referenceList[id].1 >= 0 {
                    subtractBucket(value: id, buckets: &buckets, referenceList: &referenceList)
                }
            }
            
            if minIndex > 0 {
                minIndex -= 1
            }
            if shouldPrint {
                print("\nRemoving node: ",minVal)
                print(buckets)
            }
        }
        
        
        colorStats.append( ("Min Degree",String(DEGREE_WHEN_DELETED[0])) )
        colorStats.append( ("Avg Degree",String( round( Double( totalDegree ) / Double( newList.count ) * 1000 ) / 1000 ) ) )
        colorStats.append( ("Max Degree",String(maxDegree)) )
        colorStats.append( ( "Max Degree when Deleted",String( DEGREE_WHEN_DELETED.max()!  ) ) )
        
        
        print("STATS",colorStats)
        newList.reverse()
        ORIGINAL_DEGREE.reverse()
        DEGREE_WHEN_DELETED.reverse()
        
        
        print("SETUP TIME: ",midTimeFaster.timeIntervalSince(startTimeFaster))
        
        return newList
    }

    func colorGraph(adjList: [[Node]],shouldPrint:Bool=false) -> [Int] {
        
        COLORS = []
        
        var colorsAssigned:[Int] = [Int](repeating: -1, count: adjList.count)
        
        for list in adjList {
            if shouldPrint {
                print("\nCOLORING NODE ",list[0].id)
            }
            var colorsTaken:[Int] = []
            for node in list {
                if shouldPrint && colorsAssigned[node.id] != -1 {
                    print("Color",colorsAssigned[node.id],"taken by adjacent node",node.id)
                }
                colorsTaken.append(colorsAssigned[node.id])
            }
            var k = 0
            while k < COLORS.count {
                if colorsTaken.contains(COLORS[k]) {
                    k += 1
                } else {
                    colorsAssigned[list[0].id] = COLORS[k]
                    list[0].color = COLORS[k]
                    if shouldPrint {
                        print("Assigning node",list[0].id,"the color:",list[0].color)
                    }
                    break
                }
            }
            if k == COLORS.count {
                colorsAssigned[list[0].id] = COLORS.count
                list[0].color = COLORS.count
                if shouldPrint {
                    print("Assigning node",list[0].id,"the color:",list[0].color)
                }
                COLORS.append(COLORS.count)
            }
        }

        var newNodes:[Node] = []
        for k in adjList {
            newNodes.append((k[0]))
        }
        drawView.nodes = newNodes
        
        return colorsAssigned
    }
    
    func sortColors() {
        CURRENT_COLOR_FREQUENCIES = [:]
        for num in CURRENT_COLORS_ASSIGNED {
            if CURRENT_COLOR_FREQUENCIES[num] != nil {
                CURRENT_COLOR_FREQUENCIES[num] = CURRENT_COLOR_FREQUENCIES[num]! + 1
            } else {
                CURRENT_COLOR_FREQUENCIES[num] = 1
            }
        }
        CURRENT_COLOR_FREQUENCIES_PAIRED = []
        for (k,v) in CURRENT_COLOR_FREQUENCIES {
            CURRENT_COLOR_FREQUENCIES_PAIRED.append((k,v))
        }
        CURRENT_COLOR_FREQUENCIES_PAIRED.sort { ($0.1) > ($1.1) }
    }

    @IBAction func pressedColorGraphButton(_ sender: Any) {
        
        resetSphereNetwork()
        
        let startTimeFaster = Date()
        let sorted = sortBySmallestLastDegreeFast(adjList: self.graphAdjList,shouldPrint: VERIFICATION_WALKTHROUGH)
        let midTimeFaster = Date()
        

        let midTime = Date()
        CURRENT_COLORS_ASSIGNED = colorGraph(adjList: sorted,shouldPrint:VERIFICATION_WALKTHROUGH )
        let endTime = Date()
        
        
        
        print("TIME TO SORT FAST: ",midTimeFaster.timeIntervalSince(startTimeFaster))
        
        TIME_TO_COLOR_GRAPH = endTime.timeIntervalSince(midTime)
        TIME_FOR_SMALLEST_LAST_ORDERING = midTimeFaster.timeIntervalSince(startTimeFaster)
        
        sortColors()
        
        colorStats.append( ("Number of Colors",String(COLORS.count)) )
        colorStats.append( ("Terminal Clique Size",String(TERMINAL_CLIQUE_SIZE)) )
        colorStats.append( ("Max Color Class Size",String(CURRENT_COLOR_FREQUENCIES_PAIRED[0].1)) )

        if VERIFICATION_WALKTHROUGH {
            let elements = getNodesAndEdgesFromBipartiteGraph(with: COLORS[0], secondColor: COLORS[1],shouldPrint: true)
            let parts = getComponents(edges: elements.1,shouldPrint: VERIFICATION_WALKTHROUGH)
            
            print("\nBackbone:")
            print(parts[0])
        }
        
        let beforeBipartite = Date()
        let maxEdges = getMaxBipartiteEdges()
        colorStats.append(("Max Edges in a Bipartite Subgraph",String(maxEdges)))
        bipartiteStats = []
        let maxMajorComponent = getMaxBipartiteGraphElements()
        
        let afterBipartite = Date()
        
        bipartiteStats.append(("Max Backbone Vertices",String(maxMajorComponent.1)))
        bipartiteStats.append(("Max Backbone Edges",String(maxMajorComponent.0)))
        bipartiteStats.append(("Max Backbone Domination Percentage",String(round(maxMajorComponent.2*10000)/100)))
        
        if networkModel == "Sphere" {
            bipartiteStats.append(("Max Backbone Faces",String(maxMajorComponent.0-maxMajorComponent.1+2)))
        }
        
        bipartiteStats.append(("2nd Max Backbone Vertices",String(maxMajorComponent.5)))
        bipartiteStats.append(("2nd Max Backbone Edges",String(maxMajorComponent.4)))
        bipartiteStats.append(("2nd Max Backbone Domination Percentage",String(round(maxMajorComponent.6*10000)/100)))
        
        if networkModel == "Sphere" {
            bipartiteStats.append(("2nd Max Backbone Faces",String(maxMajorComponent.4-maxMajorComponent.5+2)))
        }
        
        bipartiteStats.append(("Max Backbone Colors",String(maxMajorComponent.3.0)+" and "+String(maxMajorComponent.3.1)))
        
        bipartiteStats.append(("2nd Max Backbone Colors",String(maxMajorComponent.7.0)+" and "+String(maxMajorComponent.7.1)))
        
        
        TIME_FOR_BIPARTITE = afterBipartite.timeIntervalSince(beforeBipartite)

        generateColorValues()
        
        if networkModel == "Sphere" {
            displaySphereNetwork()
        } else {
            drawView.setNeedsDisplay()
        }
    }
    @IBAction func showValueChanged(_ sender: Any) {
        self.shouldShowNodes = self.showNodesSwitch.isOn
        self.shouldShowEdges = self.showEdgesSwitch.isOn
        drawView.shouldShowNodes = self.shouldShowNodes
        drawView.shouldShowEdges = self.shouldShowEdges
        
        if networkModel == "Sphere" {
            displaySphereNetwork()
        } else {
            drawView.setNeedsDisplay()
        }
    }
    
    @IBAction func unwindToDisplay(segue: UIStoryboardSegue) {
        print("Back at display")
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showStatsSegue" {
            let vc = (segue.destination as! UINavigationController).topViewController as! StatsTableViewController
            
            var statistics:[(String,String)] = []
            
            statistics.append(("Generate Graph (Time)",String(round(1000*TIME_TO_CREATE_GRAPH)/1000)))
            statistics.append(("Smallest Last Ordering (Time)",String(round(1000*TIME_FOR_SMALLEST_LAST_ORDERING)/1000)))
            statistics.append(("Color Graph (Time)",String(round(1000*TIME_TO_COLOR_GRAPH)/1000)))
            statistics.append(("Bipartite Stats (Time)",String(round(1000*TIME_FOR_BIPARTITE)/1000)))
            
            
            
            var colorStatistics:[(String,String)] = []
            
            colorStatistics.append(("Model",networkModel))
            
            colorStatistics.append(("Node Count (N)",String(CURRENT_NODES.count)))
            colorStatistics.append(("Connection Distance (R)",String(round(1000*CURRENT_CONNECTION_DISTANCE)/1000)))
            colorStatistics.append(("Edge Count (M)",String(CURRENT_EDGES.count)))
            
            for val in colorStats {
                colorStatistics.append(val)
            }

            
            vc.bipartiteStats = self.bipartiteStats
            vc.statistics = statistics
            vc.colorStats = colorStatistics
            
            vc.title = self.title! + "  Stats"
        }
    }
    
    @IBOutlet weak var color2Button: UIButton!
    @IBOutlet weak var color1Button: UIButton!
    var color1:Int = -1
    var color2:Int = -1
    @IBOutlet weak var colorPicker: UIPickerView!
    var selecting1 = false
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return COLORS.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(COLORS[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if selecting1 {
            color1 = COLORS[row]
            self.color1Button.setTitle("Color "+String(COLORS[row]), for: .normal)
        } else {
            color2 = COLORS[row]
            self.color2Button.setTitle("Color "+String(COLORS[row]), for: .normal)
        }
        self.showBipartiteSwitch.isEnabled = color1 != color2 && color1 != -1 && color2 != -1
        if self.showBipartiteSwitch.isOn && !self.showBipartiteSwitch.isEnabled {
            self.showBipartiteSwitch.isOn = false
        }
        colorPicker.isHidden = true
        displayBipartiteGraph()
    }
    
    func getNodesAndEdgesFromBipartiteGraph(with firstColor:Int,secondColor:Int,shouldPrint:Bool=false) -> ([Node],[Edge]) {
        var bipartiteNodes:[Node] = []
        var bipartiteEdges:[Edge] = []
        
        var nodeIds:[Int] = []
        
        if shouldPrint {
            print("Nodes for Bipartite Graph, in order:")
        }
        
        for edge in CURRENT_EDGES {
            if (edge.node1.color == firstColor && edge.node2.color == secondColor) || (edge.node1.color == secondColor && edge.node2.color == firstColor) {
                bipartiteEdges.append(edge)
                if !nodeIds.contains(edge.node1.id) {
                    nodeIds.append(edge.node1.id)
                    bipartiteNodes.append(edge.node1)
                    
                    if shouldPrint {
                        print(edge.node1)
                    }
                }
                if !nodeIds.contains(edge.node2.id) {
                    nodeIds.append(edge.node2.id)
                    bipartiteNodes.append(edge.node2)
                    if shouldPrint {
                        print(edge.node2)
                    }
                }
            }
        }
        
        if shouldPrint {
            print()
        }
        
        return (bipartiteNodes,bipartiteEdges)
    }
    

    
    @IBAction func showBipartiteSwitchChanged(_ sender: Any) {
        displayBipartiteGraph()
    }
    
    func displayBipartiteGraph() {
        if self.showBipartiteSwitch.isOn && color1 != color2 && color1 != -1 && color2 != -1 {
            resetSphereNetwork()
            
            let bipartiteGraph = getNodesAndEdgesFromBipartiteGraph(with: color1, secondColor: color2)
            
            
            if networkModel == "Sphere" {
                sphereNodes = bipartiteGraph.0
                sphereEdges = bipartiteGraph.1
                displaySphereNetwork()
            } else {
                self.drawView.nodes = bipartiteGraph.0
                self.drawView.edges = bipartiteGraph.1
                self.drawView.shouldShowExtremeEdges = false
                drawView.setNeedsDisplay()
                
            }
        } else {
            
            if networkModel == "Sphere" {
                sphereNodes = CURRENT_NODES
                sphereEdges = CURRENT_EDGES
                displaySphereNetwork()
            } else {
                self.drawView.nodes = CURRENT_NODES
                self.drawView.edges = CURRENT_EDGES
                self.drawView.shouldShowExtremeEdges = true
                drawView.setNeedsDisplay()
            }
        }
    }
    
    func getDominationPercentage(nodeIds:[Int]) -> Double {
        //calculate the domination percentage of the backbones
        var ids:Set<Int> = Set.init()
        
        //add all ids to the set
        for id in nodeIds {
            for connected in graphAdjList[id] {
                ids.insert(connected.id)
            }
        }
        
        return Double(ids.count)/Double(CURRENT_NODES.count)
    }
    
    func getMaxBipartiteGraphElements() -> (Int,Int,Double,(Int,Int),Int,Int,Double,(Int,Int)) {
        
        var maxIndex = (-1,-1)
        var maxMajorCompSize = -1
        var numberOfNodes = -1
        var maxDominationPercentage:Double = 0.0
        
        var secondMaxIndex = (-1,-1)
        var secondMaxSize = -1
        var secondNumberOfNodes = -1
        var secondDominationPercentage:Double = 0.0
        
        //find the top bipartite graphs
        for i in 0..<min(COLORS.count-1,3) {
            for j in (i+1)..<min(COLORS.count,4) {
                let elements = getNodesAndEdgesFromBipartiteGraph(with: CURRENT_COLOR_FREQUENCIES_PAIRED[i].0, secondColor: CURRENT_COLOR_FREQUENCIES_PAIRED[j].0)
                let parts = getComponents(edges: elements.1)
                if parts[0].1 > maxMajorCompSize {
                    secondMaxSize = maxMajorCompSize
                    secondMaxIndex = maxIndex
                    secondNumberOfNodes = numberOfNodes
                    secondDominationPercentage = maxDominationPercentage
                    
                    maxMajorCompSize = parts[0].1
                    maxIndex = (i,j)
                    numberOfNodes = parts[0].0.count
                    maxDominationPercentage = getDominationPercentage(nodeIds: parts[0].0)
                } else if parts[0].1 > secondMaxSize {
                    secondMaxSize = parts[0].1
                    secondMaxIndex = (i,j)
                    secondNumberOfNodes = parts[0].0.count
                    secondDominationPercentage = getDominationPercentage(nodeIds: parts[0].0)
                }
            }
        }
        
        
        return (maxMajorCompSize,numberOfNodes,maxDominationPercentage,maxIndex,secondMaxSize,secondNumberOfNodes,secondDominationPercentage,secondMaxIndex)
    }
    
    func getMaxBipartiteEdges() -> Int {
        var bipartiteEdges:[[Int]] = [[Int]](repeating: [Int](repeating: 0, count: COLORS.count ),count: COLORS.count)
        
        
        for edge in CURRENT_EDGES {
            bipartiteEdges[edge.node1.color][edge.node2.color] += 1
            bipartiteEdges[edge.node2.color][edge.node1.color] += 1
        }

        var maxEdgeCount = 0
        
        for i in 0..<COLORS.count {
            for j in i..<COLORS.count {
                if bipartiteEdges[i][j] > maxEdgeCount {
                    maxEdgeCount = bipartiteEdges[i][j]
                }
            }
        }
        
        return maxEdgeCount
    }
    
    func getComponents(edges:[Edge],shouldPrint:Bool=false) -> [([Int],Int)] {
        var components:[([Int],Int)] = []
        
        if shouldPrint {
            print("Making Components")
            print(components)
        }
        
        //find the components using the edges
        for edge in edges {
            //used for node1 and node2
            var component1 = -1
            var component2 = -1
            for i in 0..<components.count {
                if components[i].0.contains(edge.node1.id) {
                    component1 = i
                }
                if components[i].0.contains(edge.node2.id) {
                    component2 = i
                }
            }
            
            //check which of the nodes are in a component already
            if component1 != -1 && component2 != -1 {
                if component1 != component2 {
                    let smallIndex = min(component1,component2)
                    let bigIndex = max(component1,component2)
                    
                    let removed = components.remove(at: bigIndex)
                    
                    //combine the two components
                    components[smallIndex].0.append(contentsOf: removed.0)
                    components[smallIndex].1 += removed.1 + 1
                } else {
                    components[component1].1 += 1
                }
            } else if component1 != -1 {
                components[component1].0.append(edge.node2.id)
                components[component1].1 += 1
            } else if component2 != -1 {
                components[component2].0.append(edge.node1.id)
                components[component2].1 += 1
            } else {
                //make new component
                components.append( ([edge.node1.id,edge.node2.id],1) )
            }
            
            if shouldPrint {
                print(components)
            }
        }
        
        //sort by largest component first
        return components.sorted { ($0.1) > ($1.1) }
    }
    
    func findMinAndMaxDegreeNodes() -> (Int,Int) {
        var ids = (0,0)
        var min = 100000
        var max = 0
        
        for list in graphAdjList {
            if list.count > max {
                max = list.count
                ids.1 = list[0].id
            }
            else if list.count < min {
                min = list.count
                ids.0 = list[0].id
            }
        }
        
        return ids
    }
    
    
    
    @IBAction func color1ButtonPressed(_ sender: Any) {
        selecting1 = true
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        colorPicker.isHidden = COLORS.count == 0
    }
    
    @IBAction func color2ButtonPressed(_ sender: Any) {
        selecting1 = false
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        colorPicker.isHidden = COLORS.count == 0
    }
    
    


}
