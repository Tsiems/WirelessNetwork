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
var TIME_FOR_SMALLEST_LAST_ORDERING = 0.0
var CURRENT_ADJACENCY_LIST:[[Node]] = []
var CURRENT_COLORS_ASSIGNED:[Int] = []
var CURRENT_COLOR_FREQUENCIES:[Int:Int] = [:]
var CURRENT_COLOR_FREQUENCIES_PAIRED:[(Int,Int)] = []
var COLORS:[Int] = []
var DEGREE_WHEN_DELETED:[Int] = []

//var CURRENT_MODEL_INDEX:INT = 0

func getRandomDouble() -> Double {
    return Double(Float(arc4random()) / Float(UINT32_MAX))
}

func getRandomFloat() -> Float {
    return Float(arc4random()) / Float(UINT32_MAX)
}

class DisplayViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource  {

    
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
    var bipartiteStats:[(String,String)] = []
    
    var graphAdjList:[[Node]] = []

    @IBOutlet weak var drawView: DisplayView!
    @IBOutlet weak var showNodesSwitch: UISwitch!
    @IBOutlet weak var showEdgesSwitch: UISwitch!
    
    @IBOutlet weak var showBipartiteSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNodesSwitch.isOn = shouldShowNodes
        showEdgesSwitch.isOn = shouldShowEdges
        
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        
        self.showBipartiteSwitch.isEnabled = color1 != color2 && color1 != -1 && color2 != -1
        
        
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
            
            let x = xMin + Double( Int( Double(i) * xMax / divider) % Int( xMax ) )
            let y = yMin + yMax / divider * Double( Int( Double(i) * yMax / divider) / Int( yMax ) )
            let id = current_id
            
            current_id += 1
            nodes.append( Node(x:x,y:y,id:id, color: 0 ) )
        }
        
        return nodes
    }
    
    func generateRandomNodesOnRect(num:Int,xMin:Double,yMin:Double,xMax:Double,yMax:Double) -> [Node]{
        var nodes:[Node] = []
        var current_id = 0
        for _ in 0 ..< num {
            
            let x = xMin + (xMax-xMin) * getRandomDouble()
            let y = yMin + (yMax-yMin) * getRandomDouble()
            
            nodes.append( Node(x:x,y:y, id: current_id, color: 0 ) )
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
            nodes.append( Node(x:x,y:y, id: current_id, color: 0 ) )
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
            
            nodes.append( Node(x:x,y:y, id: current_id, color: 0 ) )
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
        print(edges.count)
        
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
    
    
    func updateValueLocation(id:Int, sortedList: inout [(Int,Int)],  referenceList: inout [([Node],Int)]) {
        let testValue = sortedList[referenceList[id].1].1
        
        var i = referenceList[id].1
        
        let value = sortedList.remove(at: i)
        while i < sortedList.count {
            if sortedList[i].1 <= testValue {
                break
            }
            else {
                //swap values to keep in order
//                swap(&sortedList[i], &sortedList[i-1])
                
                //update reference list
                referenceList[sortedList[i].0].1 = i
//                referenceList[sortedList[i-1].0].1 = i-1
            }
            i += 1
        }
        sortedList.insert(value, at: i)
        referenceList[sortedList[i].0].1 = i
//        print("Now:",referenceList[sortedList[i].0])
    }
    
    func sortBySmallestLastDegreeFaster(adjList: [[Node]]) -> [[Node]] {
        colorStats = []
        DEGREE_WHEN_DELETED = []
        
        let startTimeFaster = Date()
        
        
        
        
        var newList:[[Node]] = []
        
        var sortedList:[(Int,Int)] = []
        
        var referenceList:[([Node],Int)] = [([Node],Int)](repeating: ([],-1), count: adjList.count)
        
        var maxDegree = 0
        var totalDegree = 0
        
        //put values in list
        for list in adjList {
            sortedList.append((list[0].id,list.count))
            if list.count-1 > maxDegree {
                maxDegree = list.count-1
            }
            totalDegree += list.count-1
        }
        
        //sort list
        sortedList.sort { ($0.1) > ($1.1) }
        
        //update reference list
        for i in 0..<sortedList.count {
            let val = sortedList[i]
            referenceList[val.0] = (adjList[val.0],i)
        }
        
        let midTimeFaster = Date()
        
        while sortedList.count > 0 {
            
            let minVal = sortedList.popLast()

            let nodeList = referenceList[minVal!.0].0
            newList.append(nodeList)
            DEGREE_WHEN_DELETED.append(minVal!.1 - 1)
            referenceList[minVal!.0].1 = -1
//            print("Removing node: ",minVal)
            let before = Date()
            for node in nodeList {
                if referenceList[node.id].1 >= 0 {
                    sortedList[referenceList[node.id].1].1 -= 1
                    
                    
                    //update location
                    updateValueLocation(id: node.id, sortedList: &sortedList, referenceList: &referenceList)
                    
                }
            }
//            print("UPDATE TIME: ", before.timeIntervalSinceNow)
        }
        
        colorStats.append( ("Min Degree w/ faster",String(DEGREE_WHEN_DELETED[0])) )
        colorStats.append( ("Avg Degree w/ faster",String( round( Double( totalDegree ) / Double( newList.count ) * 1000 ) / 1000 ) ) )
        colorStats.append( ("Max Degree w/ faster",String(maxDegree)) )
        colorStats.append( ( "Max Degree when Deleted w/ faster",String( DEGREE_WHEN_DELETED.max()!  ) ) )
        
        print("STATS",colorStats)
        newList.reverse()
        
        
        print("SETUP TIME: ",midTimeFaster.timeIntervalSince(startTimeFaster))
        
        return newList
    }
    
    func subtractBucket(value:Int,buckets: inout [[Int]], referenceList: inout [([Int],Int)]) {
        
        //iterate through current value's bucket
        for (index,nodeId) in buckets[ referenceList[value].1 ].enumerated() {
            //find node
            if nodeId == value {
                //move node to lower bucket
                
//                print("Removing")
                _ = buckets[ referenceList[value].1 ].remove(at: index)
                referenceList[value].1 -= 1
                buckets[ referenceList[value].1 ].append(value)
//                print("Adding")
                break
            }
        }
    }
    
    func sortBySmallestLastDegreeFast(adjList: [[Node]]) -> [[Node]] {
        colorStats = []
        DEGREE_WHEN_DELETED = []
        
        let startTimeFaster = Date()
        
        
        
        
        var newList:[[Node]] = []
        
        var buckets:[[Int]] = [[Int]](repeating: [], count: adjList.count-1)
        
        var referenceList:[([Int],Int)] = [([Int],Int)](repeating: ([],-1), count: adjList.count)
        
        var maxDegree = 0
        var totalDegree = 0
//        var totalEntered = 0
        
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
//            totalEntered += 1
        }
        
        //sort list
//        sortedList.sort { ($0.1) > ($1.1) }
        
        //update reference list
//        for i in 0..<sortedList.count {
//            let val = sortedList[i]
//            referenceList[val.0] = (adjList[val.0],i)
//        }
        
        let midTimeFaster = Date()
        var minIndex = 0
        while newList.count < adjList.count {
            while( buckets[minIndex].count == 0  ) {
                minIndex += 1
            }
            let minVal = buckets[minIndex].popLast()!
            
//            print(buckets)
//            let minVal = sortedList.popLast()
//            print(minVal,newList.count,adjList.count,totalEntered)
            
            
            newList.append(adjList[minVal])
            DEGREE_WHEN_DELETED.append(referenceList[minVal].1)
            referenceList[minVal].1 = -1
            //            print("Removing node: ",minVal)
//            let before = Date()
            
            let nodeList = referenceList[minVal].0
            for id in nodeList {
                if referenceList[id].1 >= 0 {
                    subtractBucket(value: id, buckets: &buckets, referenceList: &referenceList)
                }
            }
            
            if minIndex > 0 {
                minIndex -= 1
            }
            //            print("UPDATE TIME: ", before.timeIntervalSinceNow)
        }
        
        colorStats.append( ("Min Degree w/ fast",String(DEGREE_WHEN_DELETED[0])) )
        colorStats.append( ("Avg Degree w/ fast",String( round( Double( totalDegree ) / Double( newList.count ) * 1000 ) / 1000 ) ) )
        colorStats.append( ("Max Degree w/ fast",String(maxDegree)) )
        colorStats.append( ( "Max Degree when Deleted w/ fast",String( DEGREE_WHEN_DELETED.max()!  ) ) )
        
        print("STATS",colorStats)
        newList.reverse()
        
        
        print("SETUP TIME: ",midTimeFaster.timeIntervalSince(startTimeFaster))
        
        return newList
    }

    
    func sortBySmallestLastDegree(adjList: [[Node]]) -> [[Node]] {
        
        let startTime = Date()
        
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
        
        let midTime = Date()
        
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
        
        newList.reverse()
        
        let endTime = Date()
        
        
        colorStats.append( ("Min Degree",String(DEGREE_WHEN_DELETED[0])) )
        colorStats.append( ("Avg Degree",String( round( Double( totalDegree ) / Double( newList.count ) * 1000 ) / 1000 ) ) )
        colorStats.append( ("Max Degree",String(maxDegree)) )
        colorStats.append( ( "Max Degree when Deleted",String( DEGREE_WHEN_DELETED.max()!  ) ) )
        
        print("STATS",colorStats)
        
        print("SETUP TIME NORMAL: ",midTime.timeIntervalSince(startTime))
        print("REST OF TIME: ",endTime.timeIntervalSince(midTime))
        
        return newList
    }
    
    func colorGraph(adjList: [[Node]]) -> [Int] {
        
        COLORS = []
        
        var colorsAssigned:[Int] = [Int](repeating: -1, count: adjList.count)
        
        for list in adjList {
            var colorsTaken:[Int] = []
            for node in list {
                colorsTaken.append(colorsAssigned[node.id])
            }
            var k = 0
            while k < COLORS.count {
                if colorsTaken.contains(COLORS[k]) {
                    k += 1
                } else {
                    colorsAssigned[list[0].id] = COLORS[k]
                    list[0].color = COLORS[k]
                    break
                }
            }
            if k == COLORS.count {
                colorsAssigned[list[0].id] = COLORS.count
                list[0].color = COLORS.count
                COLORS.append(COLORS.count)
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
        
        let startTimeFaster = Date()
        let sorted = sortBySmallestLastDegreeFast(adjList: self.graphAdjList )
        let midTimeFaster = Date()
        
        
//        let startTime = Date()
////        let sorted = sortBySmallestLastDegree(adjList: self.graphAdjList )
        let midTime = Date()
        CURRENT_COLORS_ASSIGNED = colorGraph(adjList: sorted )
        let endTime = Date()
        
        
        
        print("TIME TO SORT FAST: ",midTimeFaster.timeIntervalSince(startTimeFaster))
        
        TIME_TO_COLOR_GRAPH = endTime.timeIntervalSince(midTime)
        TIME_FOR_SMALLEST_LAST_ORDERING = midTimeFaster.timeIntervalSince(startTimeFaster)
        
        sortColors()
        
//        print("Max Edges: ",getMaxBipartiteGraphElements())
//        let startTime1 = Date()
        
        
        let maxEdges = getMaxBipartiteEdges()
        colorStats.append(("Max Edges in a Bipartite Subgraph",String(maxEdges)))
//        print("Max Edges faster: ", maxEdges)
        bipartiteStats = []
        let maxMajorComponent = getMaxBipartiteGraphElements()
        bipartiteStats.append(("Max Backbone Vertices",String(maxMajorComponent.1)))
        bipartiteStats.append(("Max Backbone Edges",String(maxMajorComponent.0)))
        bipartiteStats.append(("Max Backbone Domination Percentage",String(round(10000*Float(maxMajorComponent.1)/Float(CURRENT_NODES.count))/100)))
//        bipartiteStats.append(("Max Backbone Colors",String(maxMajorComponent.2.0)+" and "+String(maxMajorComponent.2.1)))
        
        bipartiteStats.append(("2nd Max Backbone Vertices",String(maxMajorComponent.4)))
        bipartiteStats.append(("2nd Max Backbone Edges",String(maxMajorComponent.3)))
        bipartiteStats.append(("2nd Max Backbone Domination Percentage",String(round(10000*Float(maxMajorComponent.4)/Float(CURRENT_NODES.count))/100)))
//        bipartiteStats.append(("2nd Max Backbone Colors",String(maxMajorComponent.5.0)+" and "+String(maxMajorComponent.5.1)))
        
        
        

//        let startTime2 = Date()
//        print("Times: ", startTime1.timeIntervalSince(endTime), " | ",startTime2.timeIntervalSince(startTime1))
        generateColorValues()
        
        
        drawView.setNeedsDisplay()
    }
    @IBAction func showValueChanged(_ sender: Any) {
        self.shouldShowNodes = self.showNodesSwitch.isOn
        self.shouldShowEdges = self.showEdgesSwitch.isOn
        drawView.shouldShowNodes = self.shouldShowNodes
        drawView.shouldShowEdges = self.shouldShowEdges
        
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
            
            statistics.append(("Model",networkModel))
            
            statistics.append(("Node Count (N)",String(CURRENT_NODES.count)))
            statistics.append(("Edge Count (E)",String(CURRENT_EDGES.count)))
            
            statistics.append(("Connection Distance (R)",String(round(1000*CURRENT_CONNECTION_DISTANCE)/1000)))
//            statistics.append(("Average Degree",String(round(1000*2.0*Double(CURRENT_EDGES.count)/Double(CURRENT_NODES.count))/1000)))
            
            for val in colorStats {
                statistics.append(val)
            }
            
            statistics.append(("Generate Graph (Time)",String(round(1000*TIME_TO_CREATE_GRAPH)/1000)))
            statistics.append(("Smallest Last Ordering (Time)",String(round(1000*TIME_FOR_SMALLEST_LAST_ORDERING)/1000)))
            statistics.append(("Color Graph (Time)",String(round(1000*TIME_TO_COLOR_GRAPH)/1000)))
            
            vc.bipartiteStats = self.bipartiteStats
            vc.statistics = statistics

            
            //            CURRENT_MODEL_INDEX = self.networkModelControl.selectedSegmentIndex
        }
    }
    
    @IBOutlet weak var color2Button: UIButton!
    @IBOutlet weak var color1Button: UIButton!
    var color1:Int = -1
    var color2:Int = -1
//    @IBOutlet var colorPicker: UIPickerView!
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
    
    func getNodesAndEdgesFromBipartiteGraph(with firstColor:Int,secondColor:Int) -> ([Node],[Edge]) {
        var bipartiteNodes:[Node] = []
        var bipartiteEdges:[Edge] = []
        
        var nodeIds:[Int] = []
        
        for edge in CURRENT_EDGES {
            if (edge.node1.color == firstColor && edge.node2.color == secondColor) || (edge.node1.color == secondColor && edge.node2.color == firstColor) {
                bipartiteEdges.append(edge)
                if !nodeIds.contains(edge.node1.id) {
                    nodeIds.append(edge.node1.id)
                    bipartiteNodes.append(edge.node1)
                }
                if !nodeIds.contains(edge.node2.id) {
                    nodeIds.append(edge.node2.id)
                    bipartiteNodes.append(edge.node2)
                }
            }
        }
        return (bipartiteNodes,bipartiteEdges)
    }
    

    
    @IBAction func showBipartiteSwitchChanged(_ sender: Any) {
        displayBipartiteGraph()
    }
    
    func displayBipartiteGraph() {
        if self.showBipartiteSwitch.isOn && color1 != color2 && color1 != -1 && color2 != -1 {
            print("Works!")
            
            
            let bipartiteGraph = getNodesAndEdgesFromBipartiteGraph(with: color1, secondColor: color2)
            
            print( getComponents(edges: bipartiteGraph.1) )
            
            self.drawView.nodes = bipartiteGraph.0
            self.drawView.edges = bipartiteGraph.1
            self.drawView.setNeedsDisplay()
        } else {
            self.drawView.nodes = CURRENT_NODES
            self.drawView.edges = CURRENT_EDGES
            self.drawView.setNeedsDisplay()
        }
    }
    
    func getMaxBipartiteGraphElements() -> (Int,Int,(Int,Int),Int,Int,(Int,Int)) {
        
        var maxIndex = (-1,-1)
        var maxMajorCompSize = -1
        var numberOfNodes = -1
        
        var secondMaxIndex = (-1,-1)
        var secondMaxSize = -1
        var secondNumberOfNodes = -1
        
        for i in 0..<min(COLORS.count-1,3) {
            for j in (i+1)..<min(COLORS.count,4) {
                let elements = getNodesAndEdgesFromBipartiteGraph(with: CURRENT_COLOR_FREQUENCIES_PAIRED[i].0, secondColor: CURRENT_COLOR_FREQUENCIES_PAIRED[j].0)
                let parts = getComponents(edges: elements.1)
                if parts[0].1 > maxMajorCompSize {
                    secondMaxSize = maxMajorCompSize
                    secondMaxIndex = maxIndex
                    secondNumberOfNodes = numberOfNodes
                    
                    maxMajorCompSize = parts[0].1
                    maxIndex = (i,j)
                    numberOfNodes = parts[0].0.count
                } else if parts[0].1 > secondMaxSize {
                    secondMaxSize = parts[0].1
                    secondMaxIndex = (i,j)
                    secondNumberOfNodes = parts[0].0.count
                }
            }
        }
        
        
        return (maxMajorCompSize,numberOfNodes,maxIndex,secondMaxSize,secondNumberOfNodes,secondMaxIndex)
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
    
    func getComponents(edges:[Edge]) -> [([Int],Int)] {
        var components:[([Int],Int)] = []
        
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
                components.append( ([edge.node1.id,edge.node2.id],2) )
            }
        }
        
        //sort by largest component first
        return components.sorted { ($0.1) > ($1.1) }
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
