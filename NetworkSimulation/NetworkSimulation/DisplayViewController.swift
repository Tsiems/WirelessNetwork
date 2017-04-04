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
var TIME_TO_CREATE_GRAPH = 0.0
var TIME_TO_COLOR_GRAPH = 0.0
var CURRENT_ADJACENCY_LIST:[[Node]] = []
var CURRENT_COLORS_ASSIGNED:[Int] = []
var DEGREE_WHEN_DELETED:[Int] = []
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
    
    var colorStats:[(String,String)] = []
    
    var graphAdjList:[[Node]] = []

    @IBOutlet weak var drawView: DisplayView!
    @IBOutlet weak var showNodesSwitch: UISwitch!
    @IBOutlet weak var showEdgesSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        var nodes:[Node] = [Node(x:50,y:100),Node(x:50,y:150),Node(x:100,y:100), Node(x:100,y:150)]
        
     //   let screenSize = UIScreen.main.bounds
      //  let screenWidth = Double(screenSize.width)
        //let screenHeight = Double(screenSize.height)
        
        
//        let nodes = generateRandomNodesOnRect(num: nodeCount, xMin: 50, yMin: 100, xMax: 50+squareEdgeSize, yMax: 100+squareEdgeSize)
        
        
        CURRENT_CONNECTION_DISTANCE = connectionDistance
        
        let startTime = Date()
        if shouldGenerateNewValues {
            if networkModel == "Disk" {
                let nodes = generateRandomNodesInDisk(num: nodeCount)
                CURRENT_NODES = nodes
            }
            else {
                let nodes = generateRandomNodesInSquare(num: nodeCount)
                CURRENT_NODES = nodes
            }
//            var edges:[Edge] = generateEdgesBruteForce(nodes: CURRENT_NODES, r: connectionDistance)
            let edges:[Edge] = generateEdgesUsingCellMethod(nodes: CURRENT_NODES, r: connectionDistance)
            CURRENT_EDGES = edges
        }
        
        let graphCreatedTime = Date()
        
        TIME_TO_CREATE_GRAPH = graphCreatedTime.timeIntervalSince(startTime)
        
        self.graphAdjList = getAdjacencyList(nodes: CURRENT_NODES, edges: CURRENT_EDGES)
        CURRENT_ADJACENCY_LIST = self.graphAdjList
        
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
            
            let x = (r * cos(degree) + 1.0)/2.0
            let y = (r * sin(degree) + 1.0)/2.0
            
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
//                    print("Connecting for real: ",nodes[i],nodes[j])
                }
            }
        }
        print(edges.count)
        
        return edges
    }
    
    func generateEdgesUsingCellMethod(nodes:[Node], r:Double) -> [Edge] {
        // WARNING: this is very slow and is O(n^2)
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
        
        
//        for i in 0 ..< nodes.count-1 {
//            for j in i+1 ..< nodes.count {
//                if sqrt( pow(nodes[i].x-nodes[j].x,2) + pow(nodes[i].y-nodes[j].y,2)) <= r {
//                    edges.append( Edge(node1: nodes[i],node2: nodes[j]))
//                }
//            }
//        }
        
        return edges
    }
    
    func findDifference(list1:[Edge],list2:[Edge]) {
        for i1 in list1 {
            var found = false
            for i2 in list2 {
                if (i1.node1.id == i2.node1.id && i1.node2.id == i2.node2.id) || (i1.node1.id == i2.node2.id && i1.node2.id == i2.node1.id){
                    found = true
                    break
                }
            }
            if !found {
                let r = connectionDistance
                print(i1.node1,i1.node2, "    ", Int(i1.node1.x/r), Int(i1.node1.y/r), " --- ", Int(i1.node2.x/r), Int(i1.node2.y/r))
            }
        }
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
        
//        print(adjList)
        
        return adjList
    }
    
    func sortBySmallestLastDegree(adjList: [[Node]]) -> [[Node]] {
        colorStats = []
        DEGREE_WHEN_DELETED = []
        
        var newList:[[Node]] = []
        
        
        var adjDict:[Int:([Node],Int)] = [:]
        
        var maxDegree = 0
        var totalDegree = 0
        for list in adjList {
            adjDict[list[0].id] = (list,list.count)
            if list.count-1 > maxDegree {
                maxDegree = list.count-1
            }
            totalDegree += list.count-1
        }
        
        while adjDict.count > 0 {
            var minDegree = 1000000
            var minDegreeId = -1
            for (k,v) in adjDict {
                if v.1 < minDegree {
                    minDegree = v.1
                    minDegreeId = k
                }
            }
            
            let minVal = adjDict.removeValue(forKey: minDegreeId)
            newList.append(minVal!.0)
            DEGREE_WHEN_DELETED.append(minVal!.1 - 1)
            for node in minVal!.0 {
                if adjDict[node.id] != nil {
                    adjDict[node.id]!.1 -= 1
                }
            }
        }
        
        colorStats.append( ("Min Degree",String(DEGREE_WHEN_DELETED[0])) )
        colorStats.append( ("Avg Degree",String( round( Double( totalDegree ) / Double( newList.count ) * 1000 ) / 1000 ) ) )
        colorStats.append( ("Max Degree",String(maxDegree)) )
        colorStats.append( ( "Max Degree when Deleted",String( DEGREE_WHEN_DELETED.max()!  ) ) )
        
        print("STATS",colorStats)
        newList.reverse()
        
        return newList
    }
    
    func colorGraph(adjList: [[Node]]) -> [Int] {
//        let sortedArray = arr.sort { ($0[0] as? Int) < ($1[0] as? Int) }
//        var edges:[(Int,Int)] = []
        var colors:[Int] = []
        var colorValues:[UIColor] = []
        
        var colorsAssigned:[Int] = [Int](repeating: -1, count: adjList.count)
        
        for list in adjList {
            var colorsTaken:[Int] = []
            for node in list {
                colorsTaken.append(colorsAssigned[node.id])
            }
            var k = 0
            while k < colors.count {
                if colorsTaken.contains(colors[k]) {
                    k += 1
                } else {
                    colorsAssigned[list[0].id] = colors[k]
                    list[0].color = colorValues[k]
                    break
                }
            }
            if k == colors.count {
                colorsAssigned[list[0].id] = colors.count
                colors.append(colors.count)
                let newColor = UIColor(colorLiteralRed: getRandomFloat(), green: getRandomFloat(), blue: getRandomFloat(), alpha: 1.0)
                colorValues.append(newColor)
                list[0].color = newColor
            }
        }
        
//        print(colorsAssigned)
        

        
        
//        var adjListCopy = adjList
//        var removedNodes:[Int] = []
//        var i = 0
        
        
//        // VERY SLOW VERSION!
//        while i < adjListCopy.count {
//            var minListCount:Int = Int(INT_MAX)
//            var minId = -1
//            
//            //find min
//            for list in adjListCopy {
//                if list.count < minListCount && !removedNodes.contains(list[0].id) {
//                    minId = list[0].id
//                    minListCount = list.count
//                }
//            }
//            
//            removedNodes.append(minId)
//            for node in adjListCopy[minId] {
//                if node.id != minId {
//                    var j = 0
//                    
//                    while j < adjListCopy[node.id].count {
//                        if adjListCopy[node.id][j].id == minId {
//                            break
//                        }
//                        
//                        j += 1
//                    }
//                    adjListCopy[node.id].remove(at: j)
//                }
//            }
//            
//            i += 1
//        }
        
//        print(removedNodes)
        
        //sort adjacency list
        
        //Loop until list is empty
            //pop the lowest into new list
        
            //update all values it was connected to (or sort again but that's slow)
        
        
        var newNodes:[Node] = []
        for k in adjList {
            newNodes.append((k[0]))
        }
        drawView.nodes = newNodes
        
        return colorsAssigned
    }

    @IBAction func pressedColorGraphButton(_ sender: Any) {
        let startTime = Date()
        CURRENT_COLORS_ASSIGNED = colorGraph(adjList: sortBySmallestLastDegree(adjList: self.graphAdjList ) )
        let endTime = Date()
        
        TIME_TO_COLOR_GRAPH = endTime.timeIntervalSince(startTime)
        drawView.setNeedsDisplay()
    }
    @IBAction func showValueChanged(_ sender: Any) {
        self.shouldShowNodes = self.showNodesSwitch.isOn
        self.shouldShowEdges = self.showEdgesSwitch.isOn
        drawView.shouldShowNodes = self.shouldShowNodes
        drawView.shouldShowEdges = self.shouldShowEdges
//        if self.shouldShowEdges {
//            let edges:[Edge] = generateEdgesBruteForce(nodes: CURRENT_NODES, r: connectionDistance)
//            
////            findDifference(list1: edges, list2: CURRENT_EDGES)
//            CURRENT_EDGES = edges
//            drawView.edges = CURRENT_EDGES
//        } else {
//            let edges:[Edge] = generateEdgesUsingCellMethod(nodes: CURRENT_NODES, r: connectionDistance)
//            CURRENT_EDGES = edges
//            drawView.edges = CURRENT_EDGES
//        }
        drawView.setNeedsDisplay()
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
            
            statistics.append(("Node Count (N)",String(CURRENT_NODES.count)))
            statistics.append(("Edge Count (E)",String(CURRENT_EDGES.count)))
            statistics.append(("Connection Distance (R)",String(round(1000*CURRENT_CONNECTION_DISTANCE)/1000)))
//            statistics.append(("Average Degree",String(round(1000*2.0*Double(CURRENT_EDGES.count)/Double(CURRENT_NODES.count))/1000)))
            
            for val in colorStats {
                statistics.append(val)
            }
            
            statistics.append(("Generate Graph (Time)",String(round(1000*TIME_TO_CREATE_GRAPH)/1000)))
            statistics.append(("Color Graph (Time)",String(round(1000*TIME_TO_COLOR_GRAPH)/1000)))
            
            vc.statistics = statistics

            
            //            CURRENT_MODEL_INDEX = self.networkModelControl.selectedSegmentIndex
        }
    }


}
