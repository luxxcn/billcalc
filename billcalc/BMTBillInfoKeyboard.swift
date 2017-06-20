//
//  BMTBillInfoKeyboard.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/6/11.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

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
    
    var bankTypeButtons = [UIButton?]()
    
    var moneyDateButtons = [UIButton?]()
    var selectedMoney = true
    
    let selectedImage = sColorHelper.imageFrom(color: UIColor.gray)
    let normalImage = sColorHelper.imageFrom(color: UIColor.white)
    
    override init(textField: UITextField?, searchBar: UISearchBar?) {
        
        super.init(textField: textField, searchBar: searchBar)
        textField?.delegate = self
    }
    
    convenience init(textField: UITextField?) {
        
        self.init(textField: textField, searchBar: nil)
        
        // bank type
        let count = BankType.count
        var buttonFrame = self.frame
        buttonFrame.size.height = frame.height / CGFloat(count)
        buttonFrame.size.width = frame.width / 5.0
        for i in 0..<count {
            
            buttonFrame.origin.y = buttonFrame.height * CGFloat(i) + CGFloat(1 * i)
            
            let button = UIButton(frame:buttonFrame)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(clickedBankButton(_:)), for: .touchUpInside)
            button.setBackgroundImage(normalImage, for: .normal)
            button.setTitle(BankType(rawValue: i)?.value, for: .normal)
            button.tag = i
            self.addSubview(button)
            bankTypeButtons.append(button)
        }
        
        // number
        buttonFrame.size.height = frame.height / 5.0
        buttonFrame.origin.y = 0
        for i in 1...12 {
            
            let offsetX = CGFloat((i + 2) % 3 + 1)
            buttonFrame.origin.x = buttonFrame.width * offsetX + offsetX
            if i == 4 || i == 7 || i == 10 {
                
                buttonFrame.origin.y += buttonFrame.height + 1
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
            button.setBackgroundImage(sColorHelper.imageFrom(color: UIColor.white), for: .normal)
            button.tag = i
            self.addSubview(button)
        }
        
        // 金额、日期
        var titles = ["金额", "到期日"]
        buttonFrame.origin.x = buttonFrame.width + 1
        buttonFrame.origin.y += buttonFrame.height + 1
        buttonFrame.size.width *= 3 / 2
        
        for i in 0...1 {
            
            buttonFrame.origin.x += buttonFrame.width * CGFloat(i) + CGFloat(i)
            buttonFrame.size.width += CGFloat(i)
            
            let button = UIButton(frame: buttonFrame)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setBackgroundImage(sColorHelper.imageFrom(color: UIColor.white), for: .normal)
            button.setTitle(titles[i], for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(clickedMoneyDateButton(_:)), for: .touchUpInside)
            self.addSubview(button)
            self.moneyDateButtons.append(button)
        }
        
        // < ↑ ⬇️ + -
        titles = ["<-", "⬆️", "⬇️", "+", "-"]
        buttonFrame.origin.y = 0
        buttonFrame.size.width = frame.width / 5
        buttonFrame.origin.x = buttonFrame.width * 4 + 4
        for i in 0..<titles.count {
            
            buttonFrame.origin.y = buttonFrame.height * CGFloat(i) + CGFloat(1 * i)
            
            let button = UIButton(frame: buttonFrame)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setBackgroundImage(sColorHelper.imageFrom(color: UIColor.white), for: .normal)
            button.setTitle(titles[i], for: .normal)
            button.tag = i
            self.addSubview(button)
            
            // touch up inside
            if i == 0 {
                
                button.addTarget(self, action: #selector(clickedBackspaceButton), for: .touchUpInside)
            }
            
            // select button
            if i == 1 || i == 2 {
                
                button.addTarget(self, action: #selector(clickedSelectButton(_:)), for: .touchUpInside)
                
            }
            
            // adjust button
            if i == 3 || i == 4 {
                
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        sLogic.currSelected = IndexPath(row: -1, section: 0)
        sLogic.reloadData()
    }
    
    func clickedNumButton(_ sender: UIButton) {
        
        let num = sender.titleLabel?.text
        if selectedMoney {
            
            sLogic.updateBill(addMoney: num!)
        } else {
            
            sLogic.updateBill(endDate: num!)
        }
    }
    
    func clickedBackspaceButton() {
        
        if selectedMoney {
            
            sLogic.backspaceMoney()
        } else {
            
            sLogic.backspaceDate()
        }
    }
    
    func clickedSelectButton(_ sender: UIButton) {
        
        sLogic.selectBill(up: sender.tag == 1)
    }
    
    func clickedAdjustButton(_ sender: UIButton) {
        
        sLogic.adjustPrice(add: sender.tag == 3)
    }
    
    func touchedAddButtonLongTime(_ sender: UIButton) {
        
        sLogic.adjustPrice(add: true)
    }
    
    func touchedMinusButtonLongTime(_ sender: UIButton) {
        
        sLogic.adjustPrice(add: false)
    }
    
    func clickedBankButton(_ sender: UIButton) {
        
        let bankType = BankType(rawValue: sender.tag)
        sLogic.updateBill(bankType: bankType!)
        
        self.selectBankTypeButton(at: sender.tag)
    }
    
    func clickedMoneyDateButton(_ sender: UIButton) {
        
        selectedMoneyButton(sender.tag == 0)
    }
    
    func selectedMoneyButton(_ selected: Bool) {
        
        selectedMoney = selected
        self.moneyDateButtons[0]?.setBackgroundImage(selected ? selectedImage : normalImage, for: .normal)
        self.moneyDateButtons[1]?.setBackgroundImage(!selected ? selectedImage : normalImage, for: .normal)
    }
    
    func selectBankTypeButton(at index: Int) {
        
        for button in bankTypeButtons {
            
            button?.setBackgroundImage(normalImage, for: .normal)
        }
        self.bankTypeButtons[index]?.setBackgroundImage(selectedImage, for: .normal)
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
