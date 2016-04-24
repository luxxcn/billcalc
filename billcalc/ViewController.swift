//
//  ViewController.swift
//  billcalc
//
//  Created by xxing on 16/3/10.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit
import CoreData

let D_DAY:Int = 24 * 3600
let WEEK_CN:[String] = ["一", "二", "三", "四", "五", "六", "日"]

extension NSDate {
    func dayOfWeek()->Int{
        let interval = self.timeIntervalSince1970;
        let days = Int(interval) / D_DAY;
        return Int((days - 3) % 7);
    }
    
    func daysSinceToday()->Int{
        var today = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.stringFromDate(today)
        today = formatter.dateFromString(todayStr)! //抹掉时间，只保留日期，便于准确到期天数
        //self = formatter.dateFromString(formatter.stringFromDate(self))
        
        return Int(self.timeIntervalSinceDate(today)) / D_DAY
    }
    
    func format(format:String)->String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

extension NSString {
    func isPureInt()->Bool{
        let scanner:NSScanner = NSScanner(string: self as String)
        return scanner.scanInt(UnsafeMutablePointer<Int32>.alloc(1)) && scanner.atEnd
    }
    
    func isPureFloat()->Bool{
        let scanner:NSScanner = NSScanner(string: self as String)
        return scanner.scanFloat(UnsafeMutablePointer<Float>.alloc(1)) && scanner.atEnd
    }
    
    func isNumeric()->Bool{
        return self.isPureFloat() || self.isPureInt()
    }
}

enum CalcStatus
{
    case NeedDate
    case ErrorDate
    case NeedRate
    case NeedMoney
    case End
}

class ViewController: UIViewController {

    @IBOutlet weak var labDetail: UILabel!
    @IBOutlet weak var labMain: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var btnRateTypes: [UIButton]!
    
    var status:CalcStatus = CalcStatus.End
    var rateType:Int = 0
    let dateFmt = NSDateFormatter()
    //let numberFmt = NSNumberFormatter()
    
    //var days:Int = 0
    var endDate:NSDate = NSDate()
    var today:NSDate = NSDate()
    var adddays:Int = 3
    var monthRate:Double = 0.00 //月利率
    var rate:Double = 0.00 //买断
    var money:Double = 0.00
    
    var maxGuid = g_rates.count
    //var dbRate:Rate = Rate() //存入库数据的数据
    
    var fontMedium = UIFont.systemFontOfSize(24.0, weight: 0.3)
    var fontLight = UIFont.systemFontOfSize(24.0, weight: -0.7)
    var needMoney:Bool = false
    //var auto:Bool = false //自动计算下一步
    let details:[String] = ["输入到期日", "输入利率", "输入金额"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dateFmt.dateFormat = "yyyy-MM-dd";

        for btn in buttons
        {
            btn.setBackgroundImage(imageWithColor(UIColor.grayColor()), forState: UIControlState.Highlighted)
        }
        
        NSLog("数据库Rate:%d条", g_rates.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageWithColor(color:UIColor)->UIImage {
        let rect:CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
    
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // set, true格式化，false还原
    /*func formatMoney(money:String, set:Bool)->String {
        var content = money
        let number = numberFmt.numberFromString(money)
        if(set)
        {
            content = numberFmt.stringFromNumber(number!)!
        }
        else
        {
            content = (number?.stringValue)!
        }
        return content
    }

    
    func wanYuan(money:Double)->String{
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
        return String(format: "%@万", formatMoney(String(result), set:true))
    }
*/
    
    @IBAction func rateSelect(sender: UIButton) {
        if(rateType == sender.tag)
        {
            return
        }
        
        rateType = sender.tag
        for btn in btnRateTypes
        {
            if(btn.tag == rateType)
            {
                btn.titleLabel?.font = fontMedium;
            }
            else
            {
                btn.titleLabel?.font = fontLight;
            }
        }
    }
    
    @IBAction func needMoney(sender: UIButton) {
        needMoney = !needMoney
        sender.titleLabel?.font = needMoney ? fontMedium : fontLight
        if(needMoney && rate > 0 && status == .End && labDetail.text != "")
        {
            var dates:[String] = dateFmt.stringFromDate(endDate).componentsSeparatedByString("-")
            
            let days = endDate.daysSinceToday()
            let weekDay = endDate.dayOfWeek()
            
            labDetail.text! = String(format: "%@月%@日 周%@,%d+%d天\r\n月%.2f‰, 年%.2f%%, 扣%.3f%%", dates[1], dates[2], WEEK_CN[weekDay], days, adddays, monthRate * 10.0, monthRate * 12.0, rate)
            
            labMain.text = details[2]
            status = .NeedMoney
        }
    }

    @IBAction func clickNumber(sender: UIButton) {
        var max_len = 4
        let number:String = (sender.titleLabel?.text)!
        
        if((labMain.text)!.rangeOfString(",") == nil && !(labMain.text! as NSString).isNumeric())
        {
            labMain.text = ""
        }
        
        switch(status)
        {
        case .End:
            labDetail.text = ""
            labMain.text = ""
            status = .NeedDate
            //labDetail.font = UIFont.systemFontOfSize(24.0)
        case .NeedDate:
            break
        case .NeedMoney:
            max_len = 14 //100,000,000.00，应该判断金额大小还是字符串长度呢？
        case .NeedRate:
            max_len = 5
        default:
            break;
        }
        
        var content:String = (labMain.text)!
        
        if(content.characters.count >= max_len) // 0808 ＝ 8月8日  或  3.15
        {
            return
        }
        
        if(number == "00" && (status == .NeedDate || content.characters.count + 2 >= max_len))
        {
            return
        }
        
        if(number == ".")
        {
            if(content.rangeOfString(".") != nil || status == .NeedDate)
            {
                return
            }
            if(content == "")
            {
                labMain.text = "0."
                return
            }
            if(content.rangeOfString(".") == nil)
            {
                content += "."
                labMain.text = content
                return
            }
        }
        
        if(content == details[1])
        {
            content = ""
        }
        
        if(status != .NeedDate && content != "" && content.rangeOfString(".") == nil)
        {
            //content = formatMoney(content, set: false)
            content = sMoneyHandle.formatMoney(content, set: false)
        }
        content += number;
        
        if(status == .NeedMoney && Double(content) >= 1000000000.00) //10亿内计算
        {
            return
        }
        
        if(status != .NeedDate && content.rangeOfString(".") == nil)
        {
            content = sMoneyHandle.formatMoney(content, set: true)
        }
        labMain.text = content
    }

    @IBAction func doReset(sender: UIButton) {
        labMain.text = details[0]
        labDetail.text = ""
        rate = 0.0
        adddays = 3
        status = .End
    }
    
    @IBAction func backspace(sender: UIButton) {
        var content:NSString = labMain.text!
        if(status == .End || (labMain.text)!.rangeOfString(",") == nil && !content.isNumeric())
        {
            return
        }
        if(content.length == 1)
        {
            switch status
            {
            case .NeedRate:
                content = details[1]
            case .NeedMoney:
                content = details[2]
            default:// needdate, end
                content = details[0]
                status = .End
            }
        }
        else
        {
            if((labMain.text)!.rangeOfString(",") != nil && labMain.text?.rangeOfString(".") == nil)
            {
                content = sMoneyHandle.formatMoney(content as String, set: false)
                content = content.substringToIndex(content.length - 1)
                content = sMoneyHandle.formatMoney(content as String, set: true)
            }
            else
            {
                content = content.substringToIndex(content.length - 1)
            }
        }
        labMain.text = content as String
    }
    
    // 反悔：1,日期转化错误  2,2月最后一日不正确
    func isInvalidDate(year:Int, month:Int, day:Int)->Int {
        var errorDate = 0;
        var maxMonthDay = 30

        switch month{
        case 1,3,5,7,8,10,12:
            maxMonthDay = 31
        case 4,6,9,11:
            break
        case 2:
            if((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
            {
                maxMonthDay = 29
            }
            else
            {
                maxMonthDay = 28
                if(day == 29)
                {
                    errorDate = 2
                }
            }
            break
        default:
            errorDate = 1
            break
        }
        
        if(day < 1 || day > maxMonthDay)
        {
            errorDate = 1;
        }
        return errorDate;
    }
    
    func calcDays()->Bool{
        let content:NSString = labMain.text!;
        if(content.length < 2)
        {
            return false
        }
        
        
        //today = NSDate()
        let todayStr = dateFmt.stringFromDate(today)
        today = dateFmt.dateFromString(todayStr)! //抹掉时间，只保留日期，便于准确到期天数
        var dates:[String] = todayStr.componentsSeparatedByString("-")
        var year = dates[0]
        let month = dates[1]
        let day = dates[2]
        
        // 日期输入的4位，则前两位为月，后两位为日
        var endMonth = ""
        var endDay = ""
        switch content.length
        {
        case 2:
            endMonth = content.substringToIndex(1)
            endDay = content.substringWithRange(NSRange(location: 1, length: 1))
        case 3:
            endMonth = content.substringToIndex(1)
            endDay = content.substringWithRange(NSRange(location: 1, length: 2))
        default:// 4
            endMonth = content.substringToIndex(2)
            endDay = content.substringWithRange(NSRange(location: 2, length: 2))
        }
        
        //如果到期日比当前日小，则年份加1年
        if(Int(endMonth) < Int(month) || (Int(endMonth) == Int(month) && Int(endDay) < Int(day)))
        {
            year = String(Int(year)! + 1)
        }
        
        //判断到期日是否有效
        let error = isInvalidDate(Int(year)!, month: Int(endMonth)!, day: Int(endDay)!)
        if(error > 0)
        {
            if(error == 2)
            {
                labDetail.text = String(format: "日期格式错误:%s年2月没有29日", year)
            }
            else
            {
                labDetail.text = "日期格式错误,输入前两位为月份,后两位为日期,如:0131表示为1月31日"
            }
            
            return false
        }
        
        endDate = dateFmt.dateFromString(year + "-" + endMonth + "-" + endDay)!
        
        dates = dateFmt.stringFromDate(endDate).componentsSeparatedByString("-")
        endMonth = dates[1]
        endDay = dates[2]
        
        let days = endDate.daysSinceToday()
        //labMain.text = String(days)
        let weekDay = endDate.dayOfWeek()
        adddays = 3
        if(weekDay == 5)
        {
            adddays += 2;
        }
        else if(weekDay == 6)
        {
            adddays += 1;
        }
        labDetail.text =
            endMonth + "月" + endDay + "日 周"+WEEK_CN[weekDay] + "," + String(days) + "+" + String(adddays) + "天"
        return true;
    }
    
    @IBAction func doOK(sender: UIButton) {
        
        let content:NSString = labMain.text!;
        
        if(!content.isNumeric() && (labMain.text)!.rangeOfString(",") == nil)
        {
            return;
        }
        
        switch status
        {
        case .NeedDate://输入日期，或到期天数，或金额，3位数判断为天数，4位数判断为日期，5位数以上判断为金额
            if(calcDays())
            {
                status = .NeedRate
                labMain.text = details[1]
            }
        case .NeedRate:
            rate = Double(labMain.text!)!
            let days = endDate.daysSinceToday()
            if(rateType == 0)
            {
                monthRate = rate / 10.0
            }
            else if(rateType == 1) //年化
            {
                monthRate = rate / 12.0
            }
            else if(rateType == 2) //直接设置买断扣息
            {
                monthRate = rate / Double(days + adddays) * 30.0
            }
            if(rateType != 2)
            {
                rate = monthRate / 30.0 * Double(days + adddays)
            }
            
            labDetail.text!
                += String(format: "\r\n月%.2f‰, 年%.2f%%", monthRate * 10.0, monthRate * 12.0)
            if(needMoney)
            {
                labMain.text = details[2]
                labDetail.text! += String(format: ", 扣%.3f%%",rate)
                status = .NeedMoney
            }
            else
            {
                labMain.text = String(format:"%.4f", rate)
                
                let dbRate = Rate()
                dbRate.guid = maxGuid
                maxGuid += 1 // warning
                dbRate.date = today.timeIntervalSince1970
                dbRate.endDate = endDate.timeIntervalSince1970
                dbRate.monthRate = monthRate
                dbRate.adddays = adddays
                dbRate.rate = rate
                dbRate.saveToDB();
                g_rates.append(dbRate)
                status = .End
            }
        case .NeedMoney:
            money = Double(sMoneyHandle.formatMoney(labMain.text!, set: false))!
            let cutMoney = money * rate / 100
            labDetail.text! += String(format: "\r\n金额:%@, 扣息:%.2f", sMoneyHandle.wanYuan(money), cutMoney)
            let result = String(format: "%.2f", money - cutMoney)
            labMain.text = sMoneyHandle.formatMoney(result, set: true)
            //update
            var dbRate = Rate.GetRateByGuid(maxGuid - 1)
            if(dbRate == nil
                || (dbRate?.money as! Double > 0.0 && dbRate?.money as! Double != money))
            {
                //金额不同则新建一个记录
                dbRate = Rate()
                g_rates.append(dbRate!)
            }
            dbRate!.money = money
            dbRate!.date = today.timeIntervalSince1970
            dbRate!.endDate = endDate.timeIntervalSince1970
            dbRate!.monthRate = monthRate
            dbRate!.adddays = adddays
            dbRate!.rate = rate
            dbRate!.saveToDB();
            
            status = .End
        case .End:
            labDetail.text = ""
            labMain.text = details[0]
        default:
            break
        }
    }
    
}

