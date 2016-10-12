//
//  DateTimeHandle.swift
//  billcalc
//
//  Created by xxing on 16/7/31.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit

let D_DAY:Int = 24 * 3600
let WEEK_CN:[String] = ["一", "二", "三", "四", "五", "六", "日"]

extension Date {
    func dayOfWeek()->Int{
        let interval = self.timeIntervalSince1970;
        let days = Int(interval) / D_DAY;
        return Int((days - 3) % 7);
    }
    
    func daysSinceToday()->Int{
        var today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: today)
        today = formatter.date(from: todayStr)! //抹掉时间，只保留日期，便于准确到期天数
        //self = formatter.dateFromString(formatter.stringFromDate(self))
        
        return Int(self.timeIntervalSince(today)) / D_DAY
    }
    
    func format(_ format:String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

class DateTimeHandle: NSObject {

}
