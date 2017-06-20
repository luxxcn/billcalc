//
//  BMTKeyboard.swift
//  BillMaster2
//
//  Created by 星 鲁 on 2016/12/26.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit

let HEADER_HEIGHT: Int = 35
var KEYBOARD_HEIGHT: CGFloat = 311
let NUM_PAD_DONE_BUTTON_TAG = 1999
let SCREEN_SIZE = UIScreen.main.bounds.size

class BMTKeyboard: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let textField: UITextField?
    let searchBar: UISearchBar?
    
    init(textField: UITextField? = nil, searchBar: UISearchBar? = nil) {
        let mainFrame = UIScreen.main.bounds
        var frame = mainFrame
        frame = CGRect(x: 0, y: mainFrame.height - KEYBOARD_HEIGHT,
                       width: mainFrame.width, height: KEYBOARD_HEIGHT)
        self.textField = textField
        self.searchBar = searchBar
        super.init(frame: frame)
        
        textField?.inputAccessoryView = BMTKeyboardHeader(textField: textField)
        searchBar?.inputAccessoryView = BMTKeyboardHeader(searchBar: searchBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        textField = nil
        searchBar = nil
        super.init(coder: aDecoder)
    }
    
    func hideKyeboard() {
        
        textField?.resignFirstResponder()
    }
    
    // 实现不理想，不见建议使用，在系统键盘上添加完成按钮
    /*static func addDoneButton(_ target: Any?, action: Selector) {
        
        let btnDone = UIButton(type: .custom)
        btnDone.frame = CGRect(x: 0, y: SCREEN_SIZE.height - 53, width: SCREEN_SIZE.width / 3 - 2, height: 53)
        btnDone.tag = NUM_PAD_DONE_BUTTON_TAG
        btnDone.adjustsImageWhenHighlighted = false
        btnDone.setTitle("完成", for: .normal)
        //btnDone.backgroundColor = UIColor.red
        btnDone.setTitleColor(UIColor.black, for: .normal)
        btnDone.addTarget(target, action: action, for: .touchUpInside)
        
        let windowArr = UIApplication.shared.windows
        if windowArr.count > 1 {
            
            let needWindow = windowArr[windowArr.count - 1]
            needWindow.addSubview(btnDone)
        }
    }
    
    static func removeDoneButton() {
        
        for window in UIApplication.shared.windows {
            if let btnDone = window.viewWithTag(NUM_PAD_DONE_BUTTON_TAG) {
                btnDone.removeFromSuperview()
            }
        }
    }*/
}

class BMTKeyboardHeader: UIView {
    
    var textField: UITextField?
    var mySearchBar: UISearchBar?
    var btnChangeNumber:UIButton?
    var keyboardType = UIKeyboardType.default// TODO: 可以删掉
    
    var isNumBoard = false
    
    var showNumButton:Bool {
        
        set(value) {
            btnChangeNumber?.isHidden = !value
        }
        get {
            return !(btnChangeNumber?.isHidden)!
        }
    }
    
    init(textField: UITextField? = nil, searchBar: UISearchBar? = nil, showNumButton: Bool = false) {
        
        var frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: HEADER_HEIGHT)
        frame.origin.x = 0
        frame.origin.y = -CGFloat(HEADER_HEIGHT)
        frame.size.height = CGFloat(HEADER_HEIGHT)
        
        super.init(frame: frame)
        
        self.backgroundColor = sColorHelper.colorFrom(hex: 0xd1d5db)
        var setFrame = CGRect(x: Int(frame.width - 75), y: 0, width: 75,
                              height: HEADER_HEIGHT)
        let btnHide = UIButton(frame: setFrame)
        btnHide.setTitle("隐藏键盘", for: .normal)
        btnHide.setTitleColor(sColorHelper.colorFrom(hex: 0x007aff), for: .normal)
        btnHide.titleLabel?.font = UIFont.systemFont(
            ofSize: 14, weight: UIFontWeightUltraLight)
        btnHide.addTarget(
            self,
            action: #selector(BMTKeyboardHeader.hideButtonClicked(_:)),
            for: .touchUpInside)
        addSubview(btnHide)
        
        // 切换数字键盘
        setFrame.origin.x -= 75
        btnChangeNumber = UIButton(frame: setFrame)
        btnChangeNumber?.setTitle("数字", for: .normal)
        btnChangeNumber?.setTitleColor(sColorHelper.colorFrom(hex: 0x007aff), for: .normal)
        btnChangeNumber?.titleLabel?.font = UIFont.systemFont(
            ofSize: 14, weight: UIFontWeightUltraLight)
        btnChangeNumber?.addTarget(self,
                                   action: #selector(self.changeKeyboard(_:)),
                                   for: .touchUpInside)
        btnChangeNumber?.isHidden = !showNumButton
        addSubview(btnChangeNumber!)
        
        self.textField = textField
        if textField != nil {
            self.keyboardType = (textField?.keyboardType)!
        }
        
        self.mySearchBar = searchBar
        if searchBar != nil {
            self.keyboardType = (searchBar?.keyboardType)!
        }
    }
    
    func changeKeyboard(_ seander: UIButton) {
        
        
        self.btnChangeNumber?.setTitle( isNumBoard == false ? "字符" : "数字" , for: .normal)
        if mySearchBar != nil {
            
            mySearchBar?.resignFirstResponder()
            if isNumBoard == false {
                
                for view in (self.mySearchBar?.subviews[0].subviews)! {
                    
                    if view is UITextField {
                    }
                }
                
                isNumBoard = true
                
            } else {
                
                mySearchBar?.keyboardType = self.keyboardType
                
                for view in (self.mySearchBar?.subviews[0].subviews)! {
                    
                    if view is UITextField {
                        (view as! UITextField).inputView = nil
                    }
                }
                
                isNumBoard = false
            }
            mySearchBar?.becomeFirstResponder()
        }
        
        // 未测试
        if textField != nil {
            
            textField?.resignFirstResponder()
            
            if isNumBoard == false {
                
            } else {
                
                textField?.inputView = nil
            }
            
            textField?.becomeFirstResponder()
        }
    }
    
    func hideButtonClicked(_ sender: UIButton) {
        //if textField != nil {
            textField?.resignFirstResponder()
        
        //} else if mySearchBar != nil {
            mySearchBar?.resignFirstResponder()
        //}
        
        textField?.endEditing(true)
        
        if mySearchBar != nil {
            
            mySearchBar?.keyboardType = self.keyboardType
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 键盘区域 view  /// TODO: 重新完善
class BMTKeyboardAreaView: UIView {
    
    init() {
        
        let frame = CGRect(x: 0, y: 0,
                           width: Int(UIScreen.main.bounds.width),
                           height: 210)
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 键盘按钮样式
class BMTKeyboardButton: UIButton {
    
    init(frame: CGRect, font: UIFont, title: String) {
        
        super.init(frame: frame)
        
        self.titleLabel?.font = font
        self.setTitle(title, for: .normal)
        self.backgroundColor = sColorHelper.colorFrom(hex: 0xe6e6e6)
        self.setTitleColor(UIColor.black, for: .normal)
        self.setTitleColor(UIColor.white, for: .highlighted)
        self.setBackgroundImage(
            sColorHelper.imageFrom(color: UIColor.gray), for: .highlighted)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
