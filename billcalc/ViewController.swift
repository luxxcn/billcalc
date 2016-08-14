//
//  ViewController.swift
//  billcalc
//
//  Created by xxing on 16/3/10.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit
//import CoreData


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
    
    var beganAdddays:Int = 0
    
    //var maxGuid = g_rates.count
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
        
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(ViewController.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
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
            refreshScreen()
            status = .NeedMoney
        }
        if(!needMoney && status == .NeedMoney) {
            status = .End
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
            doReset(sender)
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
        if(status != .End) {
            labMain.text = details[0]
        } else {
            labMain.text = ""
        }
        labDetail.text = ""
        endDate = NSDate()
        rate = 0.0
        money = 0.0
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
    
    // 返回：1,日期转化错误  2,2月最后一日不正确
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
            labDetail.text = "输入到期日,如：0303表示3月3日"
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
        
        //如果到期日小于等于当前日，则年份加1年
        if(Int(endMonth) < Int(month) || (Int(endMonth) == Int(month) && Int(endDay) <= Int(day)))
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
        return true;
    }
    
    func refreshScreen() {
        let days = endDate.daysSinceToday()
        if(days > 0) {
            let weekDay = endDate.dayOfWeek()
            labDetail.text = dateFmt.stringFromDate(endDate) + " 周"+WEEK_CN[weekDay] + "," + String(days) + "+" + String(adddays) + "天"
        }
        if(rate > 0) {
            if(rateType == 2) //直接设置买断扣息
            {
                monthRate = rate / Double(days + adddays) * 30.0
            } else {
                rate = monthRate / 30.0 * Double(days + adddays)
            }
            
            labDetail.text!
                += String(format: "\r\n月%.2f‰, 年%.2f%%", monthRate * 10.0, monthRate * 12.0)
            if(needMoney)
            {
                labMain.text = details[2]
                labDetail.text! += String(format: ", 扣%.3f%%",rate)
            }
            else
            {
                labMain.text = String(format:"%.4f", rate)
            }
        }
        if(money > 0) {
            let cutMoney = money * rate / 100
            labDetail.text! += String(format: "\r\n金额:%@, 扣息:%.2f", sMoneyHandle.wanYuan(money), cutMoney)
            let result = String(format: "%.2f", money - cutMoney)
            labMain.text = sMoneyHandle.formatMoney(result, set: true)
        }
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
                refreshScreen()
                status = .NeedRate
                labMain.text = details[1]
            }
        case .NeedRate:
            rate = Double(sMoneyHandle.formatMoney(labMain.text!, set: false))!//有逗号会出错
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
            
            refreshScreen()
            if(needMoney)
            {
                labMain.text = details[2]
                status = .NeedMoney
            }
            else
            {
                status = .End
            }
        case .NeedMoney:
            money = Double(sMoneyHandle.formatMoney(labMain.text!, set: false))!
            if(money > 0) {
                refreshScreen()
            }
            status = .End
        case .End:
            labDetail.text = ""
            labMain.text = details[0]
        default:
            break
        }
    }
    
    func handlePanGesture(sender:UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        if(sender.state == .Began) {
            beganAdddays = adddays
        }
        if(sender.state == .Changed){
            if(endDate.daysSinceToday() > 0) {
                let changeAddDays = Int(translation.x / 10.0)
                adddays = beganAdddays + changeAddDays
                adddays = adddays < 0 ? 0 : adddays
                refreshScreen()
            }
        }
    }
    
}

