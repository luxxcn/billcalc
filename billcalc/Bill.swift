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
            
            return days + 3
        }
    }
    
    var price:Double {
        
        get {
            
            if self.daysSinceToday == 0 {
                
                return priceAdd
            }
            
            let days = self.daysSinceToday
            
            let myMoney = money == "" ? 0.0 : Double(money)!
            
            var rate = 0.0
            let baseRate = sLogic.baseRate?[self.bankType.rawValue]
            if baseRate != nil {
                
                if baseRate != "" && baseRate != " " {
                    rate = Double(baseRate!)!
                }
            }
            
            // adjust rate
            var charge = 0.0
            let adjustRate = sLogic.getRightAdjustRate(money: myMoney)
            if adjustRate != nil {
                
                rate += Double((adjustRate?.rate)!)
                charge += Double((adjustRate?.charge)!)
            }
            charge /= 1000.0
            
            rate = rate * Double(days) / 300 + charge
            
            // 调整为2位小数
            rate = Double(String(format: "%.2f", rate))!
            
            return rate + priceAdd
        }
    }
}
