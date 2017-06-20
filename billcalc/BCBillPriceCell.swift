//
//  BCBillPriceCell.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/6/12.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

class BCBillPriceCell: UITableViewCell {

    @IBOutlet weak var labMoney: UILabel!
    @IBOutlet weak var labBankType: UILabel!
    @IBOutlet weak var labEndDate: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    
    var controller:QuotationListController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        
        let point = touches.first?.location(in: self)
        controller?.touchedMoney = (point?.x)! <= UIScreen.main.bounds.width / 2
    }

}
