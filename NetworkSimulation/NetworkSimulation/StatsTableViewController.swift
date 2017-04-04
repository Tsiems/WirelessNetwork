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
    
    var graphs:[String] = ["Degree Distribution","Color Frequency","Degree When Deleted"]
    
    var graphData:[Double] = []
    var graphTitle:String = ""
    var graphDescription:String = ""
    var graphAxisLabel:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return statistics.count
        case 1:
            return graphs.count
        default:
            return statistics.count
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
            vc.chartTitle = self.graphTitle
            vc.chartDataLabel = self.graphAxisLabel
            vc.chartDescription = self.graphDescription
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
                    case "Degree When Deleted":
                        self.graphAxisLabel = "Degree"
                        self.graphDescription = "Degree When Each Vertex was Deleted in the Smallest-Last Coloring Algorithm"
                        
                        self.graphData = [Double](repeating: 0.0, count: DEGREE_WHEN_DELETED.count)
                        var i = 0
                        for val in DEGREE_WHEN_DELETED {
                            self.graphData[i] = Double(val)
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