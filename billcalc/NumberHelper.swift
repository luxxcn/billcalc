//
//  NumberHelper.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/7/9.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

let sNumberHelper = NumberHelper()

class NumberHelper {
    
    let numberFomatter = NumberFormatter()
    
    let numbersCN = ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"]
    let unitsCN0 = ["仟", "佰", "拾", ""]
    let unitsCN1 = ["亿", "万", "元"]
    
    init() {
        
        numberFomatter.numberStyle = .decimal
    }
    
    func formatNumber(_ value: NSNumber, withStyle style: NumberFormatter.Style = .decimal) -> String? {
        
        return numberFomatter.string(from: value)
    }
    
    // 中文大写
    func formatAmountCN(_ value: NSNumber) -> String? {
        
        return formatAmountCN(value.stringValue)
    }
    
    func formatAmountCN(_ value: String) -> String? {
        
        if value.characters.count == 0 {
            return nil
        }
        
        var range = value.range(of: ".")
        var begin = Int(value)
        var end = 0
        if range != nil {
            
            begin = Int(value.substring(to: (range?.lowerBound)!))
            end = Int(Float(String(format: "0.%@", value.substring(from: (range?.upperBound)!)))! * 100)
        }
        
        var result = ""
        var base = 100000000
        var temp = begin! / base
        begin = begin! % base
        for i in 0..<3 {
            
            if temp > 0 {
                
                var d = 1000
                for j in 0...3 {
                    
                    let index = temp / d
                    temp %= d
                    d /= 10
                    if index == 0 && result.lengthOfBytes(using: .utf8) > 0 {
                        
                        if d > 0 && temp / d > 0 {
                            
                            result.append(String(format: "%@", numbersCN[index]))
                        }
                    } else if index > 0 && index < 10 {
                        
                        result.append(String(format: "%@%@", numbersCN[index], unitsCN0[j]))
                    }
                }
                if result.lengthOfBytes(using: .utf8) > 0 {
                    
                    result.append(unitsCN1[i])
                }
            }
            
            base /= 10000
            if base > 0 {
                
                temp = begin! / base
                begin = begin! % base
            }
        }
        range = result.range(of: "元")
        if result.lengthOfBytes(using: .utf8) > 0 && range == nil {
            
            result.append("元")
        }
        
        // 角、分
        if end > 0 {
            
            var index = end / 10
            if index > 0 {
                
                result.append(String(format: "%@角", numbersCN[index]))
            } else {
                
                result.append("零")
            }
            
            index = end % 10
            if index > 0 {
                
                result.append(String(format: "%@分", numbersCN[index]))
            } else {
                
                result.append("整")
            }
        } else if result.lengthOfBytes(using: .utf8) > 0 {
            
            result.append("整")
        }
        
        return result
    }
}
