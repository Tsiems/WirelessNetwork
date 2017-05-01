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

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        self.displayNetworkSwitch.isOn = false
        self.adjacencyTypeControl.selectedSegmentIndex = 1
        displayAdjacencyValue()
        
        self.title = "Wireless Sensor Network Generator"
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        
        if let amt = Float(self.adjacencyLabel.text!){
            if self.adjacencyTypeControl.selectedSegmentIndex == 0 && amt < self.adjacencySlider.maximumValue {
                self.adjacencySlider.value = amt
            } else if self.adjacencyTypeControl.selectedSegmentIndex == 1 {
                
                let nodeCount = Int(self.nodeNumberSlider.value)
                var r:Float = 0.0
                switch networkModelControl.titleForSegment(at: networkModelControl.selectedSegmentIndex)! {
                case "Square":
                    r = sqrt(amt/Float(nodeCount)/Float.pi)
                case "Disk":
                    r = sqrt(amt/Float(nodeCount))
                case "Sphere":
                    r = sqrt(amt/Float(nodeCount))
                default:
                    r = sqrt(amt/Float(nodeCount)/Float.pi)
                }
                
                if r < self.adjacencySlider.maximumValue && r != self.adjacencySlider.value {
                    self.adjacencySlider.value = r
                    self.newValuesSwitch.isOn = true
                }
                else {
                    displayAdjacencyValue()
                }
            }
            else {
                displayAdjacencyValue()
            }
        } else {
            displayAdjacencyValue()
        }
        
        
        if let amt = Float(self.nodeNumberLabel.text!) {
            if amt < self.nodeNumberSlider.maximumValue {
                if self.nodeNumberSlider.value != amt {
                    self.newValuesSwitch.isOn = true
                    self.nodeNumberSlider.value = amt
                    displayAdjacencyValue()
                }
            }
            else {
                self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
            }
        }
        else {
            self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
        }
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

    @IBOutlet weak var nodeNumberLabel: UITextField!
    @IBOutlet weak var newValuesSwitch: UISwitch!
    
    @IBOutlet weak var adjacencySlider: UISlider!
    
    @IBOutlet weak var adjacencyLabel: UITextField!
    @IBOutlet weak var adjacencyTypeControl: UISegmentedControl!
    
    @IBOutlet weak var displayNetworkSwitch: UISwitch!
    @IBOutlet weak var adjacencyTypeLabel: UILabel!
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
        self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
        displayAdjacencyValue()
        self.newValuesSwitch.isOn = true
    }
    
    @IBAction func nodeNumberSliderValueChanged(_ sender: Any) {
        self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
        displayAdjacencyValue()
        self.newValuesSwitch.isOn = true
        
        self.displayNetworkSwitch.isOn = Int(self.nodeNumberSlider.value) <= 16000
    }
    
    func displayAdjacencyValue() {
        let value = round(1000*self.adjacencySlider.value)/1000
        if self.adjacencyTypeControl.selectedSegmentIndex == 0 {
            self.adjacencyLabel.text = String(value)
            self.adjacencyTypeLabel.text = "R (distance for adjacency)"
        } else if self.adjacencyTypeControl.selectedSegmentIndex == 1 {
            let nodeCount = Int(self.nodeNumberSlider.value)
            var avgDegree:Float = 0.0
            switch networkModelControl.titleForSegment(at: networkModelControl.selectedSegmentIndex)! {
            case "Square":
                avgDegree = Float(nodeCount)*Float.pi*value*value
            case "Disk":
                avgDegree = Float(nodeCount)*value*value
            case "Sphere":
                avgDegree = Float(nodeCount)*value*value
            default:
                avgDegree = Float(nodeCount)*Float.pi*value*value
            }
            self.adjacencyLabel.text = String( round(1000*avgDegree)/1000 )
            self.adjacencyTypeLabel.text = "Avg (average degree)"
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
                vc.connectionDistance = vc.connectionDistance/2
            } else if vc.networkModel == "Sphere" {
                vc.averageDegree = Double(vc.nodeCount)*vc.connectionDistance*vc.connectionDistance/4
                vc.connectionDistance = vc.connectionDistance*2
            }
            
            vc.shouldGenerateNewValues = self.newValuesSwitch.isOn
            
            vc.shouldShowEdges = self.displayNetworkSwitch.isOn
            vc.shouldShowNodes = self.displayNetworkSwitch.isOn
            
            vc.title = String(vc.nodeCount)+" vertices, "+String(vc.averageDegree)+" Avg. Degree"
            vc.title = "|V| = "+String(vc.nodeCount)+" ,  Avg. Degree = "+self.adjacencyLabel.text!
        }
    }

}
