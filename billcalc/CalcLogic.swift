//
//  CalcLogic.swift
//  billcalc
//
//  Created by 星 鲁 on 2016/12/16.
//  Copyright © 2016年 xxing. All rights reserved.
//

import Foundation

/// TODO: 设置固定利率计算，只需要输入到期直接得出结果

extension String {
    func isPureInt()->Bool{
        let scanner:Scanner = Scanner(string: self)
        return scanner.scanInt32(
            UnsafeMutablePointer<Int32>.allocate(capacity: 1)) &&
            scanner.isAtEnd
    }
    
    func isPureFloat()->Bool{
        let scanner:Scanner = Scanner(string: self)
        return scanner.scanFloat(
            UnsafeMutablePointer<Float>.allocate(capacity: 1)) &&
            scanner.isAtEnd
    }
    
    func isNumeric()->Bool{
        return self.isPureFloat() || self.isPureInt()
    }
}

enum CalcPhase {
    case datePhase
    case ratePhase
    case moneyPhase
}

enum RateType: Int {
    case monthlyRateType = 0
    case yearRateType
    case percentRateType
}

class CalcLogic {
    
    var monthlyRate: Double?
    //var startDate: Int? // default is today
    var endDate: Date?
    var adddays: Int = 3
    var phase: CalcPhase = .datePhase
    var rateType: RateType = .monthlyRateType
    var needMoney = false
    var money: Double = 0.00
    var calcEnd = true
    var errorMsg:String?
    
    //let details:[String] = ["输入到期日", "输入利率", "输入金额"]
    //let tips:[String] = ["到期日", "利率", "余金额"]
    let rateTips:[String] = ["月利率", "年利率", "百分比"]
    let slogan = "成都 · 承兑汇票贴现\r\nTel. 133-0821-6781"
    
    func reset() {
        
        monthlyRate = nil
        endDate = nil
        adddays = 3
        phase = .datePhase
        money = 0.00
        calcEnd = false
        errorMsg = nil
    }
    
    func updateMainLabel(aString: String, tag: Int) -> String {
      
        var string = aString
        let number = tag
        
        if phase == .moneyPhase {
            string = sMoneyHandle.unformat(money: string)
        }
        
        switch tag {
        case 10000: // ok
            if !calcEnd {
                return calculate(aString: string)
            }
        case 100: // "00"
            if phase != .datePhase &&
                (string.range(of: ".") != nil || Double(string)! > 0.0) {
                    string.append("00")
            }
        case 101: // "."
            if phase != .datePhase && string.characters.count > 0 {
                if string.range(of: ".") == nil {
                    string.append(".")
                }
            }
        case 1000: // backspace
            if string.characters.count > 0 && string.isNumeric() {
                var index = string.index(string.endIndex, offsetBy: -1)
                string = string.substring(to: index)
                if aString.range(of: ".")?.upperBound == aString.endIndex {
                    index = string.index(string.endIndex, offsetBy: -1)
                    string = string.substring(to: index)
                }
            }
        case 1001: // AC
            calcEnd = true
        case 1002:
            self.needMoney = !needMoney
            if needMoney && phase == .ratePhase{
                phase = .moneyPhase
                calcEnd = false
                string = "0"
            } else if phase == .moneyPhase {
                calcEnd = true
            }
        default:
            if string.isNumeric() {
                if phase == .datePhase || string.range(of: ".") != nil {
                    string.append(String(format: "%d", number))
                } else if Double(string) == 0.0  {
                    string = String(format: "%d", number)
                } else {
                    string.append(String(format: "%d", number))
                }
            } else {
                string = String(format: "%d", number)
            }
        }
        
        // 各阶段允许输入的长度
        switch phase {
        case .datePhase:
            if string.characters.count > 4 {
                string = aString
            }
        case .ratePhase:
            if string.characters.count == 0 {
                string = "0"
            }
        case .moneyPhase:
            if let range = aString.range(of: ".") {
                let index = aString.index(aString.endIndex, offsetBy: -2)
                if tag != 1000 && range.upperBound == index {
                    string = aString
                }
            }
            
            string = sMoneyHandle.format(money: string)
        }
        
        if calcEnd {
            reset()
            if tag > 9 {
                string = "输入到期日"
            } else {
                string = String(format: "%d", number)
            }
        }
        
        return string
    }
    
    func calcPercentRate(per10: Bool = false) -> Double {
        
        var rate =
            monthlyRate! / 300 * Double((endDate?.daysSinceToday())! + adddays)
        if per10 {
            rate *= 1000
        }
        
        return rate
    }
    
    func calcMonthlyRate(percentRate: Double) -> Double {
        
        return
            percentRate * 300 / Double((endDate?.daysSinceToday())! + adddays)
    }
    
    func updateTipLabel() -> String {
        
        var string = ""
        switch phase {
        case .datePhase:
            string = "到期日"
        case .ratePhase:
            string = calcEnd ? "每十万" : rateTips[rateType.rawValue]
        case .moneyPhase:
            string = calcEnd ? "余金额" : "金额"
        }
        return string
    }
    
    // 返回更新 main label
    func set(adddays: Int, mainString: String) -> String {
        
        self.adddays = adddays
        var string = mainString
        
        if calcEnd {
            if phase == .ratePhase {
                string = String(format: "%.0f", calcPercentRate(per10: true))
            } else if phase == .moneyPhase {
                let percent = calcPercentRate()
                string =
                    sMoneyHandle.format(money: money - money * percent / 100)
            }
        }
        return string
    }
    
    func updateDetailLabel() -> String {
        
        var string = ""
        
        if endDate != nil {
            string = string.appendingFormat(
                "%@ 计%d + %d天",
                sDateTimeHandle.fullDateString(from: endDate!),
                endDate!.daysSinceToday(),
                adddays
            )
        } else {
            string = errorMsg != nil ? errorMsg! : slogan
        }
        
        if monthlyRate != nil {
            
            string = string.appendingFormat(
                "\r\n月%.2f‰ 年%.2f％ 百%.2f％",
                monthlyRate!, monthlyRate! * 1.2, calcPercentRate())
        }
        
        if needMoney && money > 0.0 {
            string = string.appendingFormat(
                "\r\n金额%@元 扣息%@元", sMoneyHandle.wanYuan(money),
                sMoneyHandle.format(money: money * calcPercentRate() / 100))
        }
        
        return string
    }
    
    // 返回显示在 main label 上
    func calculate(aString: String) -> String {
        
        if aString.isNumeric() == false {
            return aString
        }
        
        var string = aString
        
        switch phase {
        case .datePhase:
            if !calcEndDate(string) {
                string = "到期日错误!"
                errorMsg =
                "日期输入格式：\r\n前两位代表月份，后两位代表日期。\r\n如：0121 表示1月21日"
            } else {
                string = "输入利率"
                adddays += sDateTimeHandle.holidayDays(from: endDate!)
                phase = .ratePhase
            }
        case .ratePhase:
            
            switch rateType {
            case .monthlyRateType:
                monthlyRate = Double(string)
            case .yearRateType:
                monthlyRate = Double(string)! / 12 * 10
            case .percentRateType:
                monthlyRate = calcMonthlyRate(percentRate: Double(string)!)
            }
            string = String(format: "%.0f", calcPercentRate(per10: true))
            if needMoney {
                string = "输入金额"
                phase = .moneyPhase
            } else {
                calcEnd = true
            }
        case .moneyPhase:
            money = Double(string)!
            let left = money - money * calcPercentRate() / 100
            string = sMoneyHandle.format(money: String(format:"%.2f", left))
            calcEnd = true
        }
        
        return string
    }
    
    func calcEndDate(_ content: String) -> Bool {

        var result = true
        let todayComponents = Date().components()
        var year = todayComponents.year!
        var month:Int?, day:Int?
        var index:String.Index?
        
        switch content.characters.count {
        case 2, 3:
            index = content.index(content.startIndex, offsetBy: 1)
        case 4:
            index = content.index(content.startIndex, offsetBy: 2)
        default:
            result = false
        }
        
        if result {
            // convert date
            month = Int(content.substring(to: index!))
            day = Int(content.substring(from: index!))
            
            if month! < todayComponents.month!
                || (month! == todayComponents.month!
                    && day! <= todayComponents.day!) {
                year += 1
            }
            
            result = sDateTimeHandle.isValidDate(year: year,
                                                 month: month!, day: day!)
        }
        
        if result {
            endDate = sDateTimeHandle.createDate(year: year,
                                                month: month!, day: day!)
        }
        
        return result
    }
    
}
