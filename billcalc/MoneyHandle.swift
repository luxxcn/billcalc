//
//  MoneyCtrl.swift
//  billcalc
//
//  Created by xxing on 16/3/29.
//  Copyright © 2016年 xxing. All rights reserved.
//

import Foundation

let sMoneyHandle = MoneyHandle()

class MoneyHandle: NSObject {
    
    static let sMoneyHandle = MoneyHandle()
    
    let numberFmt = NumberFormatter()
    
    fileprivate override init() {
        numberFmt.locale = Locale.current
        numberFmt.numberStyle = NumberFormatter.Style.decimal
        numberFmt.roundingMode = NumberFormatter.RoundingMode.floor
    }
    
    // set, true格式化，false还原
    func format(money: String, set: Bool = true)->String {
        
        let range = money.range(of: ".")
        var content = range != nil ?
            money.substring(to: (range?.lowerBound)!) : money
        let number = numberFmt.number(from: content)
        
        if number != nil {
            content = set ?
                numberFmt.string(from: number!)! : (number?.stringValue)!
        }
        
        if range != nil {
            content.append(money.substring(from: (range?.lowerBound)!))
        }
        
        return content
    }
    
    func format(money: Double) -> String {
        
        return format(money: String(format:"%.2f", money))
    }
    
    func unformat(money: String) -> String {
        return format(money: money, set: false)
    }
    
    func wanYuan(_ money:Double)->String{
        let result = String(format: "%.2f", money / 10000.00)
        return money == 0.0 ?
            "" : String(format: "%@万", format(money: result))
    }
}
