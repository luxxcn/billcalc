//
//  BCAdjustRateKeyboard.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/7/2.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

class BCAdjustRateKeyboard: BMTKeyboard {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var adjustTypeButtons = [UIButton?]()
    
    var adjustRateCell:BCAdjustRateCell?
    
    override init(textField: UITextField?, searchBar: UISearchBar?) {
        
        super.init(textField: textField, searchBar: searchBar)
    }
    
    convenience init(textField: UITextField?) {
        
        self.init(textField: textField, searchBar: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardDidHide, object: nil)
        
        // adjust type button
        var buttonFrame = CGRect(x: 0, y: 0, width: frame.width / 3.0 - 0.5, height: frame.height / 5.0 - 0.5)
        for i in 0...2 {
            
            let offset = CGFloat(i)
            buttonFrame.origin.x = offset * buttonFrame.width + offset * 0.5
            let button = UIButton(frame: buttonFrame)
            button.tag = i
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitle(AdjustRateType(rawValue: i)?.title, for: .normal)
            button.setBackgroundImage(specialNormalImage, for: .normal)
            button.setBackgroundImage(selectedImage, for: .highlighted)
            button.setBackgroundImage(selectedImage, for: .selected)
            button.addTarget(self, action: #selector(clickedAdjustButton(_:)), for: .touchUpInside)
            self.addSubview(button)
            adjustTypeButtons.append(button)
        }
        
        // num button
        buttonFrame.origin.x = 0.0
        buttonFrame.origin.y += buttonFrame.height + 0.5
        for i in 1...11 {
            
            let offset = CGFloat((i + 2) % 3)
            buttonFrame.origin.x = offset * buttonFrame.width + offset * 0.5
            
            if i == 4 || i == 7 || i == 10 {
                
                buttonFrame.origin.y += buttonFrame.height + 0.5
            }
            var title = ""
            switch i {
            case 10:
                title = "."
            case 11:
                title = "0"
            default:
                title = String(i)
            }
            
            let button = UIButton(frame: buttonFrame)
            //button.addTarget(self, action: #selector(clickedNumButton(_:)), for: .touchUpInside)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitle(title, for: .normal)
            button.setBackgroundImage(whiteImage, for: .normal)
            button.setBackgroundImage(specialNormalImage, for: .highlighted)
            button.tag = i
            button.addTarget(self, action: #selector(clickedNumButton(_:)), for: .touchUpInside)
            self.addSubview(button)
        }
        
        // backspace button
        buttonFrame.origin.x += buttonFrame.width + 0.5
        let button = UIButton(frame: buttonFrame)
        button.setBackgroundImage(specialNormalImage, for: .normal)
        button.setBackgroundImage(whiteImage, for: .highlighted)
        button.setImage(backspaceImageNormal, for: .normal)
        button.setImage(backspaceImageHighlighted, for: .highlighted)
        button.adjustsImageWhenHighlighted = false
        let edgeX = buttonFrame.width - 49
        let edgeY = buttonFrame.height - 20
        button.imageEdgeInsets = UIEdgeInsetsMake(edgeY, edgeX, edgeY, edgeX)
        button.addTarget(self, action: #selector(clickedBackspaceButton), for: .touchUpInside)
        self.addSubview(button)
    }
    
    func keyboardWillHide() {
        
        adjustRateCell?.unselected()
    }
    
    func clickedAdjustButton(_ sender: UIButton) {
        
        self.select(rateType: AdjustRateType(rawValue: sender.tag)!)
    }
    
    func select(rateType: AdjustRateType) {
        
        for button in adjustTypeButtons {
            
            if button?.tag == rateType.rawValue {
                
                button?.isSelected = true
                adjustRateCell?.select(rateType: rateType)
            } else {
                
                button?.isSelected = false
            }
        }
    }
    
    func clickedNumButton(_ sender: UIButton) {
        
        adjustRateCell?.updateLabelText(text: (sender.titleLabel?.text)!)
    }
    
    func clickedBackspaceButton() {
        
        adjustRateCell?.backspaceLabelText()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

}
