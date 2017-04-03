//
//  StatsTableViewCell.swift
//  NetworkSimulation
//
//  Created by Travis Siems on 4/2/17.
//  Copyright © 2017 Travis Siems. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    @IBOutlet weak var goButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
