//
//  BCBBaseRateCell.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/6/18.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

class BCBBaseRateCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var txtBaseRates: [UITextField]!
    var _section = -1
    var secion:Int {
        
        get {
            
            return _section
        }
        
        set {
            
            _section = newValue
            
            for textField in self.txtBaseRates {
                
                let key = String(format: "%@%d_%d", keys[textField.tag], _section, textField.tag)
                textField.text = UserDefaults.standard.value(forKey: key) as? String
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        for txtRate in self.txtBaseRates {
            
            txtRate.delegate = self
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let key = String(format: "%@%d_%d", keys[textField.tag], self.secion, textField.tag)
        UserDefaults.standard.setValue(textField.text, forKey: key)
    }
 
}

class BCBRatePer10AddCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var txtPer10Add: UITextField!
    var _section = -1
    var secion:Int {
        
        get {
            
            return _section
        }
        
        set {
            
            _section = newValue
            txtPer10Add.text = UserDefaults.standard.value(forKey: per10Key) as? String
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.txtPer10Add.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UserDefaults.standard.setValue(textField.text, forKey: per10Key)
    }
}

