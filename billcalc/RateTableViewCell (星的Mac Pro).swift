//
//  RateTableViewCell.swift
//  billcalc
//
//  Created by xxing on 16/3/29.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit

class RateTableViewCell: UITableViewCell {

    @IBOutlet weak var labMoney: UILabel!
    @IBOutlet weak var labBank: UILabel!
    @IBOutlet weak var labEndDate: UILabel!
    @IBOutlet weak var labRate: UILabel!
    
    var data:NSNumber = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
