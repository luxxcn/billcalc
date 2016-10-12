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
    func formatMoney(_ money:String, set:Bool)->String {
        var content = money
        let number = numberFmt.number(from: money)
        if(set)
        {
            content = numberFmt.string(from: number!)!
        }
        else
        {
            content = (number?.stringValue)!
        }
        return content
    }
    
    func wanYuan(_ money:Double)->String{
        let result = money / 10000.00
        /*var unit = "万"
        if(result >= 10000)
        {
        result /= 10000.00
        unit = "亿"
        }
        else if(result >= 1000)
        {
        result /= 1000.00
        unit = "千万"
        }
        */
        NSLog("money:%f", money)
        return result == 0 ? "" : String(format: "%@万", formatMoney(String(result), set:true))
    }
}
