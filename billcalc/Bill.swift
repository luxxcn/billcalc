//
//  Bill.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/6/16.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

let keys = ["state", "city", "smallCity", "country", "town", "foreign"]

let per10Key = "Per10Add"

enum BankType:Int {
    case bankTypeState = 0
    case bankTypeCity = 1
    case bankTypeSmallCity = 2
    case bankTypeCountry = 3
    case bankTypeTown = 4
    case bankTypeForegin = 5
    
    static let count:Int = 6
    var value:String {
        
        get {
            
            switch self {
            case .bankTypeState:
                return "国股"
            case .bankTypeCity:
                return "城商"
            case .bankTypeSmallCity:
                return "小商"
            case .bankTypeCountry:
                return "三农"
            case .bankTypeTown:
                return "村镇"
            case .bankTypeForegin:
                return "外资"
            }
        }
    }
    
    var key:String {
        
        get {
            
            return keys[self.rawValue]
        }
    }
}

enum DateInputStep {
    
    case month0
    case month1
    case day0
    case day1
}

class Bill: NSObject {
    
    var money = "0.00"
    var bankType:BankType = .bankTypeState
    //var endDate = sDateTimeHandle.dateSinceToday(withDays: 184).timeIntervalSince1970 // 默认半年后到期日
    
    var month = ["_", "_"]
    var day = ["_", "_"]
    var dateStep = DateInputStep.month0
    
    var priceAdd:Double = 0.0
    
    var daysSinceToday:Int {
        
        get {
            
            if self.month[0] == "_" || self.month[1] == "_" || self.day[0] == "_" || self.day[1] == "_" {
                
                return 0
            }
            
            let comps = Date().components()
            let month = Int(String(format: "%@%@", self.month[0], self.month[1]))!
            let day = Int(String(format: "%@%@", self.day[0], self.day[1]))!
            var year = comps.year!
            
            if month < comps.month! || (month == comps.month! && day <= comps.day!) {
                
                year += 1
            }
            
            let endDate = sDateTimeHandle.createDate(year: year, month: month, day: day)
            let days = (endDate?.daysSinceToday())! + sDateTimeHandle.holidayDays(from: endDate!)
            
            return days
        }
    }
    
    var price:Double {
        
        get {
            
            if self.daysSinceToday == 0 {
                
                return priceAdd
            }
            
            let days = self.daysSinceToday + 3
            
            var section = 0
            let myMoney = money == "" ? 0.0 : Double(money)!
            if myMoney >= 200 {
                section = 0
            } else if myMoney >= 100 {
                
                section = 1
            } else if myMoney >= 50 {
                
                section = 2
            } else {
                
                section = 3
            }
            let key = String(format: "%@%d_%d", self.bankType.key, section, self.bankType.rawValue)
            
            var rate = 0.0
            let baseRate = UserDefaults.standard.value(forKey: key)
            if baseRate != nil {
                
                let strRate = baseRate as! String
                rate = strRate == "" ? 0.0 : Double(strRate)!
            }
            
            var add = 0.0
            let per10Add = UserDefaults.standard.value(forKey: per10Key)
            if per10Add != nil {
                
                let strPer10Add = per10Add as! String
                add = strPer10Add == "" ? 0.0 : Double(strPer10Add)!
            }
            add /= 1000.0
            
            return rate * Double(days) / 300 + add + priceAdd
        }
    }
}
