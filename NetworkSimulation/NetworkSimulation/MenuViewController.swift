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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var nodeNumberSlider: UISlider!
    @IBOutlet weak var nodeNumberLabel: UILabel!
    @IBAction func nodeNumberSliderValueChanged(_ sender: Any) {
        self.nodeNumberLabel.text = String(Int(self.nodeNumberSlider.value))
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
            vc.nodeCount = Int(self.nodeNumberSlider.value)
        }
    }

}
