//
//  DisplayViewController.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/24/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        draw(CGRect(x: 10, y: 10, width: 10, height: 10))

        // Do any additional setup after loading the view.
        var nodes:[Node] = [Node(x:50,y:100),Node(x:50,y:150),Node(x:100,y:100), Node(x:100,y:150)]
        let edges:[Edge] = [Edge(node1:nodes[0],node2:nodes[3]),Edge(node1:nodes[2],node2:nodes[1])]
        (self.view as! DisplayView).nodes = nodes
        (self.view as! DisplayView).edges = edges
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        print("Going to menu")
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
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
