//
//  BMTBillInfoKeyboard.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/6/11.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

let selectedImage = sColorHelper.imageFrom(hex: 0xe8ecf0)
let normalImage = sColorHelper.imageFrom(color: UIColor.white)
let whiteImage = sColorHelper.imageFrom(color: UIColor.white)
let specialNormalImage = sColorHelper.imageFrom(hex: 0xd1d5da)

let backspaceImageNormal = UIImage(named: "backspace-normal")
let backspaceImageHighlighted = UIImage(named: "backspace-touched")

class BMTBillInfoKeyboard: BMTKeyboard, UITextFieldDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //var cell:BCBillPriceCell?
    //var tableView:UITableView?
    //var logic:QuotationLogic?
    var rateCell:BCBaseRateCell?
    var isSetBaseRate = false
    
    var bankTypeButtons = [UIButton?]()
    
    var moneyDateButtons = [UIButton?]()
    var selectedMoney = true
    
    override init(textField: UITextField?, searchBar: UISearchBar?) {
        
        super.init(textField: textField, searchBar: searchBar)
        textField?.delegate = self
    }
    
    convenience init(textField: UITextField?, baseRate: Bool = false) {
        
        self.init(textField: textField, searchBar: nil)
        
        self.isSetBaseRate = baseRate
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardDidHide, object: nil)
        
        // bank type
        let count = BankType.count
        var buttonFrame = self.frame
        buttonFrame.size.height = frame.height / CGFloat(count)
        buttonFrame.size.width = frame.width / 5.0
        for i in 0..<count {
            
            buttonFrame.origin.y = buttonFrame.height * CGFloat(i) + CGFloat(0.5 * Double(i))
            
            let button = UIButton(frame:buttonFrame)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(clickedBankButton(_:)), for: .touchUpInside)
            button.setBackgroundImage(specialNormalImage, for: .normal)
            button.setBackgroundImage(selectedImage, for: .highlighted)
            button.setBackgroundImage(selectedImage, for: .selected)
            button.setTitle(BankType(rawValue: i)?.value, for: .normal)
            button.tag = i
            self.addSubview(button)
            bankTypeButtons.append(button)
        }
        
        // number
        buttonFrame.size.height = isSetBaseRate ? frame.height / 4.0 : frame.height / 5.0
        buttonFrame.origin.y = 0
        for i in 1...12 {
            
            let offsetX = CGFloat(Double((i + 2) % 3) + 1)
            buttonFrame.origin.x = buttonFrame.width * offsetX + offsetX - offsetX / 2
            
            if i == 4 || i == 7 || i == 10 {
                
                buttonFrame.origin.y += buttonFrame.height + 0.5
            }
            var title = ""
            switch i {
            case 10:
                title = "."
            case 11:
                title = "0"
            case 12:
                title = "00"
            default:
                title = String(i)
            }
            
            let button = UIButton(frame: buttonFrame)
            button.addTarget(self, action: #selector(clickedNumButton(_:)), for: .touchUpInside)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitle(title, for: .normal)
            button.setBackgroundImage(whiteImage, for: .normal)
            button.setBackgroundImage(specialNormalImage, for: .highlighted)
            button.tag = i
            self.addSubview(button)
        }
        
        // 金额、日期
        var titles = ["金额", "到期日"]
        buttonFrame.origin.x = buttonFrame.width + 0.5
        buttonFrame.origin.y += buttonFrame.height + 0.5
        buttonFrame.size.width *= 3 / 2
        
        for i in 0...1 {
            
            buttonFrame.origin.x += buttonFrame.width * CGFloat(i) + CGFloat(i) / 2
            buttonFrame.size.width += CGFloat(i) / 2
            
            let button = UIButton(frame: buttonFrame)
            button.setBackgroundImage(specialNormalImage, for: .normal)
            button.setBackgroundImage(selectedImage, for: .highlighted)
            button.setBackgroundImage(selectedImage, for: .selected)
            button.setTitle(titles[i], for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(clickedMoneyDateButton(_:)), for: .touchUpInside)
            
            if isSetBaseRate == false {
                self.addSubview(button)
                self.moneyDateButtons.append(button)
            }
        }
        
        // ⌫ ↑ ⬇️ + -
        titles = ["", "⇧", "⇩", "+", "-"]
        buttonFrame.origin.y = 0
        buttonFrame.size.width = frame.width / 5.0
        buttonFrame.size.height = frame.height / 5.0
        buttonFrame.origin.x = buttonFrame.width * 4 + 2
        for i in 0..<titles.count {
            
            buttonFrame.origin.y = buttonFrame.height * CGFloat(i) + CGFloat(0.5 * Double(i))
            
            let button = UIButton(frame: buttonFrame)
            button.setTitleColor(UIColor.black, for: .normal)
            //button.setTitleColor(UIColor.white, for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: UIFontWeightRegular)
            button.setBackgroundImage(specialNormalImage, for: .normal)
            button.setBackgroundImage(whiteImage, for: .highlighted)
            button.setTitle(titles[i], for: .normal)
            button.tag = i
            self.addSubview(button)
            
            // backspace
            if i == 0 {
                
                button.setImage(backspaceImageNormal, for: .normal)
                button.setImage(backspaceImageHighlighted, for: .highlighted)
                button.adjustsImageWhenHighlighted = false
                let edgeX = buttonFrame.width - 27
                let edgeY = buttonFrame.height - 20
                button.imageEdgeInsets = UIEdgeInsetsMake(edgeY, edgeX, edgeY, edgeX)
                button.addTarget(self, action: #selector(clickedBackspaceButton(_:)), for: .touchUpInside)
            }
            
            // select button
            if i == 1 || i == 2 {
                
                button.addTarget(self, action: #selector(clickedSelectButton(_:)), for: .touchUpInside)
                
            }
            
            // adjust button
            if i == 3 || i == 4 {
                
                button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
                button.addTarget(self, action: #selector(clickedAdjustButton(_:)), for: .touchUpInside)
                if i == 3 {
                    
                    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(touchedAddButtonLongTime(_:)))
                    button.addGestureRecognizer(gesture)
                } else {
                    
                    let gesutre = UILongPressGestureRecognizer(target: self, action: #selector(touchedMinusButtonLongTime(_:)))
                    button.addGestureRecognizer(gesutre)
                }
            }
        }
    }
    
    func keyboardWillHide() {
        
        rateCell?.unselected()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if isSetBaseRate {
            
            return
        }
        
        sLogic.currSelected = IndexPath(row: -1, section: 0)
        sLogic.reloadData()
    }
    
    func clickedNumButton(_ sender: UIButton) {
        
        let num = sender.titleLabel?.text
        
        if isSetBaseRate || rateCell != nil {
            
            rateCell?.updateLabText(text: (sender.titleLabel?.text)!)
        } else {
        
            if selectedMoney {
                
                sLogic.updateBill(addMoney: num!)
            } else {
                
                sLogic.updateBill(endDate: num!)
            }
        }
    }
    
    func clickedBackspaceButton(_ sender: UIButton) {
        
        if isSetBaseRate {
            
            rateCell?.backspaceLabelText()
        } else if selectedMoney {
            
            sLogic.backspaceMoney()
        } else {
            
            sLogic.backspaceDate()
        }
        
    }
    
    func clickedSelectButton(_ sender: UIButton) {
        
        if isSetBaseRate {
            
            let currBankType = rateCell?.currentSelectedBankType
            var changeRawValue = currBankType?.rawValue
            changeRawValue = sender.tag == 1 ? changeRawValue! - 1 : changeRawValue! + 1
            
            if changeRawValue! >= BankType.bankTypeState.rawValue
                && changeRawValue! < BankType.count {
                
                self.selectBankTypeButton(at: changeRawValue!)
            }
            
        } else if sLogic.count() > 0 {
            
            sLogic.selectBill(up: sender.tag == 1)
            self.selectBankTypeButton(at: sLogic.selectedBankType().rawValue)
            self.selectedMoneyButton(true)
        }
    }
    
    func clickedAdjustButton(_ sender: UIButton) {
        
        if isSetBaseRate {
            
            rateCell?.adjustRate(add: sender.tag == 3)
        } else {
            
            sLogic.adjustPrice(add: sender.tag == 3)
        }
    }
    
    func touchedAddButtonLongTime(_ sender: UIButton) {
        
        if !isSetBaseRate {
            sLogic.adjustPrice(add: true)
        }
    }
    
    func touchedMinusButtonLongTime(_ sender: UIButton) {
        
        if !isSetBaseRate {
            sLogic.adjustPrice(add: false)
        }
    }
    
    func clickedBankButton(_ sender: UIButton) {
        
        let bankType = BankType(rawValue: sender.tag)
        
        self.selectBankTypeButton(at: sender.tag)
        
        if !isSetBaseRate {
            sLogic.updateBill(bankType: bankType!)
        }
    }
    
    func clickedMoneyDateButton(_ sender: UIButton) {
        
        selectedMoneyButton(sender.tag == 0)
    }
    
    func selectedMoneyButton(_ selected: Bool) {
        
        selectedMoney = selected
        self.moneyDateButtons[0]?.isSelected = selected
        self.moneyDateButtons[1]?.isSelected = !selected
    }
    
    func selectBankTypeButton(at index: Int) {
        
        if isSetBaseRate {
            
            rateCell?.selectBankType(bankType: BankType(rawValue: index)!)
        }
        
        for button in bankTypeButtons {
            
            button?.isSelected = false
        }
        self.bankTypeButtons[index]?.isSelected = true
    }
    
    func selectRow(at indexPath:IndexPath, touchedMoney: Bool) {
        
        sLogic.currSelected = indexPath
        self.selectedMoneyButton(touchedMoney)
        
        let banktype = sLogic.selectedBankType()
        self.selectBankTypeButton(at: banktype.rawValue)
        
        sLogic.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

}
