//
//  BCBaseRateCell.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/7/2.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit
import CoreData

let selctedColor = sColorHelper.colorFrom(hex: 0xe8ecf0)
let normalColor = UIColor.white

class BCBaseRateCell: UITableViewCell {

    @IBOutlet var bankTypeLabels: [UILabel]!
    @IBOutlet var baseRateLabels: [UILabel]!
    
    var _baseRates:BaseRate?
    var baseRates:BaseRate? {
        
        get {
            
            return _baseRates
        }
        
        set {
            
            let rates = newValue?.rates
            
            for label in baseRateLabels {
                
                label.text = (rates?.count)! > label.tag ? rates?[label.tag] : "0"
                //label.text = newValue != nil ? newValue?._rates?[label.tag] : ""
            }
            _baseRates = newValue
        }
    }
    
    var currentSelectedBankType = BankType.bankTypeState
    var currentRateLabel:UILabel? {
        
        get {
            
            for label in baseRateLabels {
                
                if label.tag == currentSelectedBankType.rawValue {
                    
                    return label
                }
            }
            
            return nil
        }
    }
    var currentLabelText:String? {
        
        get {
            
            return currentRateLabel?.text
        }
        
        set {
            
            let currentLable = currentRateLabel
            currentLable?.text = newValue
            let value = newValue == "" ? " " : newValue!
            baseRates?.rates?[(currentLable?.tag)!] = value
            do {
                
                try baseRates?.managedObjectContext?.save()
            } catch {
                
                print(error.localizedDescription)
            }
        }
    }
    
    var keyboard:BMTBillInfoKeyboard?
    
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
        
        let pointX = Double((touches.first?.location(in: self).x)!)
        let offset = Double(UIScreen.main.bounds.width / 6.0)
        let index = Int(pointX / offset)
        
        keyboard?.selectBankTypeButton(at: index)
    }
    
    
    func unselected() {
        
        for label in bankTypeLabels {
            
            label.backgroundColor = normalColor
        }
    }
    
    func selectBankType(bankType: BankType) {
        
        currentSelectedBankType = bankType
        for label in bankTypeLabels {
            
            if label.tag == bankType.rawValue {
                
                label.backgroundColor = selctedColor
            } else {
                
                label.backgroundColor = normalColor
            }
        }
    }
    
    func updateLabText(text: String) {
        
        if text == "00" {
            
            return
        }
        
        if let label = self.currentRateLabel {
            
            if label.text == "0" || label.text == "" || label.text == " "{
                
                
                let newText = text == "." ? "0." : text
                currentLabelText = newText
            } else {
                
                if text == "." {
                    
                    if label.text?.range(of: text) != nil {
                        
                        return
                    }
                }
                currentLabelText?.append(text)
            }
        }
    }
    
    func backspaceLabelText() {
        
        if let label = self.currentRateLabel {
            
            if (label.text?.characters.count)! > 0 {
                
                let index = label.text?.index((label.text?.endIndex)!, offsetBy: -1)
                currentLabelText = label.text?.substring(to: index!)
            }
        }
    }
    
    func adjustRate(add: Bool) {
        
        var text = self.currentRateLabel?.text
        text = text == "" ? "0" : text
        var value = Double(text!)!
        
        value = add ? value + 0.01 : value - 0.01
        if value > 0.0 {
            
            currentLabelText = String(format:"%.2f", value)
        } else if value == 0 {
            
            currentLabelText = "0"
        }
    }

}

enum AdjustRateType:Int {
    case adjustBaseMoney = 0
    case adjustRate = 1
    case adjustCharge = 2
    
    var title:String {
        
        switch self {
        case .adjustBaseMoney:
            return "起始金额"
        case .adjustRate:
            return "利率调整"
        case .adjustCharge:
            return "手续费"
        }
    }
}

class BCAdjustRate {
    
    var money = 0
    var rate = 0
    var charge = 0
}

class BCAdjustRateCell: UITableViewCell {
    
    var keyboard:BCAdjustRateKeyboard?
    var currSelectRateType = AdjustRateType.adjustBaseMoney
    var selectedLabel:UILabel? {
        
        get {
            
            if moneyLabel.tag == currSelectRateType.rawValue {
                
                return moneyLabel
            } else if rateLabel.tag == currSelectRateType.rawValue {
                
                return rateLabel
            } else {
                
                return chargeLabel
            }
        }
    }
    
    var _adjustRate:AdjustRate?
    var adjustRate:AdjustRate? {
        
        get {
            
            return _adjustRate
        }
        
        set {
            
            moneyLabel.text = newValue?.money?.description
            rateLabel.text = newValue?.rate?.description
            chargeLabel.text = newValue?.charge?.description
            
            self._adjustRate = newValue
        }
    }
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var chargeLabel: UILabel!
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
        
        let pointX = Double((touches.first?.location(in: self).x)!)
        let pointY = Double((touches.first?.location(in: self).y)!)
        let offsetX = Double(UIScreen.main.bounds.width / 2.0)
        let offsetY = Double(self.frame.height / 2.0)
        
        var rateType = AdjustRateType.adjustBaseMoney
        if pointY >= offsetY {
            
            if pointX < offsetX {
                
                rateType = .adjustRate
            } else {
                
                rateType = .adjustCharge
            }
        }
        sLogic.clickedAdjustRateTag = rateType
        //keyboard?.select(rateType: rateType)
    }
    
    func unselected() {
        
        for label in labels {
            
            label.backgroundColor = normalColor
        }
    }
    
    func select(rateType: AdjustRateType) {
        
        currSelectRateType = rateType
        
        for label in labels {
            
            if label.tag == rateType.rawValue {
                
                label.backgroundColor = selctedColor
            } else {
                
                label.backgroundColor = UIColor.clear
            }
        }
    }
    
    func updateRate(newValue: NSNumber, type: AdjustRateType) {
        
        switch type {
        case .adjustBaseMoney:
            adjustRate?.money = newValue
        case .adjustRate:
            adjustRate?.rate = newValue
        case .adjustCharge:
            adjustRate?.charge = newValue
        }
        
        do {
            
            try adjustRate?.managedObjectContext?.save()
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    func updateLabelText(text: String) {
        
        if let label = self.selectedLabel {
            
            if label.text == "0" && text != "." {
                
                label.text = text
            } else {
                
                if text == "." && label.text?.range(of: text) != nil {
                    
                    return
                }
                
                label.text?.append(text)
            }
            
            let rateType = AdjustRateType(rawValue: label.tag)!
            let value = Float(label.text!) as NSNumber?
            updateRate(newValue: value!, type: rateType)
        }
    }
    
    func backspaceLabelText() {
        
        if let label = self.selectedLabel {
            
            if (label.text?.characters.count)! > 0 {
                
                let index = label.text?.index((label.text?.endIndex)!, offsetBy: -1)
                label.text = label.text?.substring(to: index!)
                if label.text == "" {
                    
                    label.text = "0"
                }
                
                let rateType = AdjustRateType(rawValue: label.tag)!
                let value = Float(label.text!) as NSNumber?
                updateRate(newValue: value!, type: rateType)
            }
        }
    }
}

