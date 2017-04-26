//
//  StatsTableViewController.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 4/2/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

class StatsTableViewController: UITableViewController {
    
    var statistics:[(String,String)] = []
    var bipartiteStats:[(String,String)] = []
    
    var graphs:[String] = ["Degree Distribution","Color Frequency","Degree Deletion Analysis"]
    
    var graphData:[Double] = []
    var graphData2:[Double] = []
    var graphTitle:String = ""
    var graphDescription:String = ""
    var graphAxisLabel:String = ""
    var graphAxisLabel2:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for stat in statistics {
            print(stat.1,terminator:",")
        }
        print("\nBipartite stats: ")
//        print(bipartiteStats)
        for stat in bipartiteStats {
            print(stat.1,terminator:",")
        }
        print("\nDone")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return statistics.count
        case 1:
            return graphs.count
        case 2:
            return bipartiteStats.count
        default:
            return statistics.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Basic Stats"
        case 1:
            return "Charts"
        case 2:
            return "Bipartite Stats"
        default:
            return "Other Stats"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath) as! StatsTableViewCell
            
            cell.typeLabel.text = statistics[indexPath.row].0
            cell.valueLabel.text = statistics[indexPath.row].1

            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "generateGraphCell", for: indexPath) as! StatsTableViewCell
            
            cell.typeLabel.text = graphs[indexPath.row]
//            cell.valueLabel.text = statistics[indexPath.row].1
            
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath) as! StatsTableViewCell
            
            cell.typeLabel.text = bipartiteStats[indexPath.row].0
            cell.valueLabel.text = bipartiteStats[indexPath.row].1
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath) as! StatsTableViewCell
            
            cell.typeLabel.text = statistics[indexPath.row].0
            cell.valueLabel.text = statistics[indexPath.row].1
            
            return cell
        }
    }
    
    @IBAction func unwindToStats(segue: UIStoryboardSegue) {
        print("Back at stats")
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "graphSegue" {
            let vc = segue.destination as! GraphsViewController
            
            vc.input_data = self.graphData
            vc.input_data2 = self.graphData2
            if self.graphData2.count > 0 {
                vc.chartType = "Line"
            } else {
                vc.chartType = "Bar"
            }
            vc.chartTitle = self.graphTitle
            vc.chartDataLabel = self.graphAxisLabel
            vc.chartDataLabel2 = self.graphAxisLabel2
            vc.chartDescription = self.graphDescription

            //remove "Stats" from title
            if let titleString = self.title {
                let index = titleString.index(titleString.endIndex, offsetBy:-6)
                vc.title = titleString.substring(to: index)
            }
        }
    }
    @IBAction func goButtonPressed(_ sender: Any) {
        var indexPath: NSIndexPath!
        
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? StatsTableViewCell {
                    indexPath = self.tableView.indexPath(for: cell)! as NSIndexPath
                    print(indexPath)
                    
                    self.graphTitle = graphs[indexPath.row]
                    self.graphDescription = ""
                    self.graphAxisLabel = ""
                    self.graphData = []
                    switch self.graphTitle {
                    case "Degree Distribution":
                        self.graphAxisLabel = "Vertex Count"
                        self.graphDescription = "Degree Distribution for Verticies"
                        
                        self.graphData = [Double](repeating: 0.0, count: CURRENT_ADJACENCY_LIST.count)
                        for list in CURRENT_ADJACENCY_LIST {
                            self.graphData[list.count-1] += 1.0
                        }
                        var i = self.graphData.count-1

                        while i > -1 {
                            if self.graphData[i] == 0.0 {
                                _ = self.graphData.popLast()
                            }
                            else {
                                break
                            }
                            i -= 1
                        }
                        self.graphData2 = []
                    case "Color Frequency":
                        self.graphAxisLabel = "Vertex Count"
                        self.graphDescription = "Frequency of Verticies By Color"
                        self.graphData = [Double](repeating: 0.0, count: CURRENT_COLORS_ASSIGNED.count)
                        for num in CURRENT_COLORS_ASSIGNED {
                            self.graphData[num] += 1.0
                        }
                        var i = self.graphData.count-1
                        
                        while i > -1 {
                            if self.graphData[i] == 0.0 {
                                _ = self.graphData.popLast()
                            }
                            else {
                                break
                            }
                            i -= 1
                        }
                        self.graphData2 = []
                    case "Degree Deletion Analysis":
                        self.graphAxisLabel = "Degree When Deleted"
                        self.graphAxisLabel2 = "Original Degree"
                        self.graphDescription = ""
                        
                        self.graphData = [Double](repeating: 0.0, count: DEGREE_WHEN_DELETED.count)
                        var i = 0
                        for val in DEGREE_WHEN_DELETED {
                            self.graphData[i] = Double(val)
                            i += 1
                        }
                        
                        i = 0
                        self.graphData2 = [Double](repeating: 0.0, count: ORIGINAL_DEGREE.count)
                        for val in ORIGINAL_DEGREE {
                            self.graphData2[i] = Double(val)
                            i += 1
                        }
                        

                    default:
                        print("Graph data not created")
                    }
                    
                    print("Generating graph")
                    performSegue(withIdentifier: "graphSegue", sender: nil)
                }
            }
        }
    }


}
