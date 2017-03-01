//
//  DisplayViewController.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 2/24/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {
    
    var nodeCount = 128

    override func viewDidLoad() {
        super.viewDidLoad()
//        draw(CGRect(x: 10, y: 10, width: 10, height: 10))

        // Do any additional setup after loading the view.
//        var nodes:[Node] = [Node(x:50,y:100),Node(x:50,y:150),Node(x:100,y:100), Node(x:100,y:150)]
        var nodes = generateUniformNodes(num: nodeCount, xMin: 50, yMin: 100, xMax: 300, yMax: 550)
//        print(nodes)
        let edges:[Edge] = [Edge(node1:nodes[0],node2:nodes[3]),Edge(node1:nodes[2],node2:nodes[1])]
        (self.view as! DisplayView).nodes = nodes
        (self.view as! DisplayView).edges = edges
        (self.view as! DisplayView).NODE_SIZE = 2.0
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
        var nodes:[Node] = []
        let divider:Double = sqrt(Double(num))
        for i in 0 ..< num {
            
            // TODO: this only gets integers :(
            
            let x = xMin + Double( Int( Double(i) * xMax / divider) % Int( xMax ) )
            let y = yMin + yMax / divider * Double( Int( Double(i) * yMax / divider) / Int( yMax ) )
            nodes.append( Node(x:x,y:y ) )
        }
        
        return nodes
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
