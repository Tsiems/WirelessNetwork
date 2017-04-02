//
//  MenuViewController.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/24/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
        self.adjacencyLabel.text = String((self.adjacencySlider.value))

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.newValuesSwitch.isEnabled = CURRENT_NODES.count > 0
        self.newValuesSwitch.isOn = CURRENT_NODES.count == 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var networkModelControl: UISegmentedControl!
    @IBOutlet weak var nodeNumberSlider: UISlider!
    @IBOutlet weak var nodeNumberLabel: UILabel!
    @IBOutlet weak var newValuesSwitch: UISwitch!
    
    @IBOutlet weak var adjacencySlider: UISlider!
    @IBOutlet weak var adjacencyLabel: UILabel!
    @IBOutlet weak var adjacencyTypeControl: UISegmentedControl!
    
    @IBAction func newValuesSwitchChanged(_ sender: UISwitch) {
        
        //reset selected nodes to the number that will actually be generated
        if !self.newValuesSwitch.isOn {
            self.nodeNumberSlider.value = Float(CURRENT_NODES.count)
            self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
            self.adjacencySlider.value = Float(CURRENT_CONNECTION_DISTANCE)
            displayAdjacencyValue()
        }
    }
    @IBAction func networkModelChanged(_ sender: UISegmentedControl) {
        //reset selected nodes to the number that will actually be generated
//        if self.networkModelControl.selectedSegmentIndex != CURRENT_MODEL_INDEX {
//            self.nodeNumberSlider.value = Float(CURRENT_NODES.count)
//            self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
//        }
        self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
        displayAdjacencyValue()
        self.newValuesSwitch.isOn = true
    }
    
    @IBAction func nodeNumberSliderValueChanged(_ sender: Any) {
        self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
        displayAdjacencyValue()
        self.newValuesSwitch.isOn = true
    }
    
    func displayAdjacencyValue() {
        let value = round(1000*self.adjacencySlider.value)/1000
        if self.adjacencyTypeControl.selectedSegmentIndex == 0 {
            self.adjacencyLabel.text = String(value)
        } else if self.adjacencyTypeControl.selectedSegmentIndex == 1 {
            let nodeCount = Int(self.nodeNumberSlider.value)
            var avgDegree:Float = 0.0
            switch networkModelControl.titleForSegment(at: networkModelControl.selectedSegmentIndex)! {
            case "Square":
                avgDegree = Float(nodeCount)*Float.pi*value*value
            case "Disk":
                avgDegree = Float(nodeCount)*value*value
            default:
                avgDegree = Float(nodeCount)*Float.pi*value*value
            }
            self.adjacencyLabel.text = String( round(1000*avgDegree)/1000 )
        }

    }
    
    @IBAction func adjacencySliderChanged(_ sender: UISlider) {
        displayAdjacencyValue()
        self.newValuesSwitch.isOn = true
    }
    @IBAction func adjacencyTypeChanged(_ sender: UISegmentedControl) {
        displayAdjacencyValue()
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        print("Back at menu")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "displayNetworkSegue" {
            let vc = segue.destination as! DisplayViewController
            vc.networkModel = networkModelControl.titleForSegment(at: networkModelControl.selectedSegmentIndex)!
            vc.nodeCount = Int(self.nodeNumberSlider.value)
            vc.connectionDistance = Double(round(1000*self.adjacencySlider.value)/1000)
            if vc.networkModel == "Square" {
                vc.averageDegree = Double(vc.nodeCount)*Double.pi*vc.connectionDistance*vc.connectionDistance
            } else if vc.networkModel == "Disk" {
                vc.averageDegree = Double(vc.nodeCount)*vc.connectionDistance*vc.connectionDistance
            }
            
            
            print(vc.averageDegree)
            vc.shouldGenerateNewValues = self.newValuesSwitch.isOn
            
            
//            CURRENT_MODEL_INDEX = self.networkModelControl.selectedSegmentIndex
        }
    }

}
