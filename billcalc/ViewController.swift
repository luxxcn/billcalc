//
//  ViewController.swift
//  billcalc
//
//  Created by xxing on 16/3/10.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

//import CoreData


extension NSString {
    func isPureInt()->Bool{
        let scanner:Scanner = Scanner(string: self as String)
        return scanner.scanInt32(UnsafeMutablePointer<Int32>.allocate(capacity: 1)) && scanner.isAtEnd
    }
    
    func isPureFloat()->Bool{
        let scanner:Scanner = Scanner(string: self as String)
        return scanner.scanFloat(UnsafeMutablePointer<Float>.allocate(capacity: 1)) && scanner.isAtEnd
    }
    
    func isNumeric()->Bool{
        return self.isPureFloat() || self.isPureInt()
    }
}

enum CalcStatus
{
    case needDate
    case errorDate
    case needRate
    case needMoney
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var labDetail: UILabel!
    @IBOutlet weak var labMain: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var btnRateTypes: [UIButton]!
    
    var labTip = UILabel()
    
    var status:CalcStatus = CalcStatus.end
    var rateType:Int = 0
    let dateFmt = DateFormatter()
    //let numberFmt = NSNumberFormatter()
    
    //var days:Int = 0
    var endDate:Date = Date()
    var today:Date = Date()
    var adddays:Int = 3
    var monthRate:Double = 0.00 //月利率
    var rate:Double = 0.00 //买断
    var money:Double = 0.00
    
    var beganAdddays:Int = 0
    
    //var maxGuid = g_rates.count
    //var dbRate:Rate = Rate() //存入库数据的数据
    
    var fontMedium = UIFont.systemFont(ofSize: 24.0, weight: 0.3)
    var fontLight = UIFont.systemFont(ofSize: 24.0, weight: -0.7)
    var needMoney:Bool = false
    //var auto:Bool = false //自动计算下一步
    let details:[String] = ["输入到期日", "输入利率", "输入金额"]
    let tips:[String] = ["到期日", "利率", "余金额"]
    let rateTips:[String] = ["月利率", "年利率", "百分比"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dateFmt.dateFormat = "yyyy-MM-dd";

        for btn in buttons
        {
            btn.setBackgroundImage(imageWithColor(UIColor.gray), for: UIControlState.highlighted)
        }
        
        //let labTip = UILabel()
        let content:NSString = NSString(string: tips[0])
        let attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 20)]
        let txtSize = content.boundingRect(with: CGSize(width:100, height:100), options: NSStringDrawingOptions.truncatesLastVisibleLine, attributes: attributes, context: nil).size
        let frame = UIScreen.main.bounds
        labTip.layer.masksToBounds = true
        labTip.layer.cornerRadius = 5
        labTip.text = content as String
        labTip.textAlignment = .center
        labTip.backgroundColor = UIColor.gray
        labTip.textColor = UIColor.white
        labTip.frame = CGRect(x: frame.width - txtSize.width - 20, y: 3, width: txtSize.width, height: txtSize.height)
        labMain.addSubview(labTip)
        
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(ViewController.handlePanGesture(_:)))
        //todo: 只设置显示区可以出发滑动，因为会影响点击按钮效果。
        //labMain.gestureRecognizers = nil
        //labMain.addGestureRecognizer(panGesture)
        //labDetail.addGestureRecognizer(panGesture)
        //labMain.userInteractionEnabled = true
        self.view.addGestureRecognizer(panGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageWithColor(_ color:UIColor)->UIImage {
        let rect:CGRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
    
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func rateSelect(_ sender: UIButton) {
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
        if(status == .needRate) {
            labTip.text = rateTips[rateType]
        }
    }
    
    @IBAction func needMoney(_ sender: UIButton) {
        needMoney = !needMoney
        sender.titleLabel?.font = needMoney ? fontMedium : fontLight
        if(needMoney && rate > 0 && status == .end && labDetail.text != "")
        {
            refreshScreen()
            status = .needMoney
        }
        if(!needMoney && status == .needMoney) {
            status = .end
        }
        labTip.text = "票金额"
    }

    @IBAction func clickNumber(_ sender: UIButton) {
        var max_len = 4
        let number:String = (sender.titleLabel?.text)!
        
        if((labMain.text)!.range(of: ",") == nil && !(labMain.text! as NSString).isNumeric())
        {
            labMain.text = ""
        }
        
        switch(status)
        {
        case .end:
            doReset(sender)
            status = .needDate
            //labDetail.font = UIFont.systemFontOfSize(24.0)
        case .needDate:
            break
        case .needMoney:
            max_len = 14 //100,000,000.00，应该判断金额大小还是字符串长度呢？
        case .needRate:
            max_len = 5
        default:
            break;
        }
        
        var content:String = (labMain.text)!
        
        if(content.characters.count >= max_len) // 0808 ＝ 8月8日  或  3.15
        {
            return
        }
        
        if(number == "00" && (status == .needDate || content.characters.count + 2 >= max_len))
        {
            return
        }
        
        if(number == ".")
        {
            if(content.range(of: ".") != nil || status == .needDate)
            {
                return
            }
            if(content == "")
            {
                labMain.text = "0."
                return
            }
            if(content.range(of: ".") == nil)
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
        
        if(status != .needDate && content != "" && content.range(of: ".") == nil)
        {
            //content = formatMoney(content, set: false)
            content = sMoneyHandle.formatMoney(content, set: false)
        }
        content += number;
        
        if(status == .needMoney && Double(content) >= 1000000000.00) //10亿内计算
        {
            return
        }
        
        if(status != .needDate && content.range(of: ".") == nil)
        {
            content = sMoneyHandle.formatMoney(content, set: true)
        }
        labMain.text = content
    }

    @IBAction func doReset(_ sender: UIButton) {
        if(status != .end) {
            labMain.text = details[0]
            labTip.text = tips[0]
            labDetail.text = "成都承兑汇票贴现、转让：\r\n电话13308216781"
        } else {
            labMain.text = ""
            labTip.text = tips[0]
            labDetail.text = ""
        }
        
        endDate = Date()
        rate = 0.0
        money = 0.0
        adddays = 3
        status = .end
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        var content:NSString = labMain.text! as NSString
        if(status == .end || (labMain.text)!.range(of: ",") == nil && !content.isNumeric())
        {
            return
        }
        if(content.length == 1)
        {
            switch status
            {
            case .needRate:
                content = details[1] as NSString
            case .needMoney:
                content = details[2] as NSString
            default:// needdate, end
                content = details[0] as NSString
                status = .end
            }
        }
        else
        {
            if((labMain.text)!.range(of: ",") != nil && labMain.text?.range(of: ".") == nil)
            {
                content = sMoneyHandle.formatMoney(content as String, set: false) as NSString
                content = content.substring(to: content.length - 1) as NSString
                content = sMoneyHandle.formatMoney(content as String, set: true) as NSString
            }
            else
            {
                content = content.substring(to: content.length - 1) as NSString
            }
        }
        labMain.text = content as String
    }
    
    // 返回：1,日期转化错误  2,2月最后一日不正确
    func isInvalidDate(_ year:Int, month:Int, day:Int)->Int {
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
        let content:NSString = labMain.text! as NSString;
        if(content.length < 2)
        {
            labDetail.text = "输入到期日,如：0303表示3月3日"
            return false
        }
        
        
        //today = NSDate()
        let todayStr = dateFmt.string(from: today)
        today = dateFmt.date(from: todayStr)! //抹掉时间，只保留日期，便于准确到期天数
        var dates:[String] = todayStr.components(separatedBy: "-")
        var year = dates[0]
        let month = dates[1]
        let day = dates[2]
        
        // 日期输入的4位，则前两位为月，后两位为日
        var endMonth = ""
        var endDay = ""
        switch content.length
        {
        case 2:
            endMonth = content.substring(to: 1)
            endDay = content.substring(with: NSRange(location: 1, length: 1))
        case 3:
            endMonth = content.substring(to: 1)
            endDay = content.substring(with: NSRange(location: 1, length: 2))
        default:// 4
            endMonth = content.substring(to: 2)
            endDay = content.substring(with: NSRange(location: 2, length: 2))
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
        
        endDate = dateFmt.date(from: year + "-" + endMonth + "-" + endDay)!
        
        dates = dateFmt.string(from: endDate).components(separatedBy: "-")
        
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
            labDetail.text = dateFmt.string(from: endDate) + " 周"+WEEK_CN[weekDay] + "," + String(days) + "+" + String(adddays) + "天"
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
    
    @IBAction func doOK(_ sender: UIButton) {
        
        let content:NSString = labMain.text! as NSString;
        
        if(!content.isNumeric() && (labMain.text)!.range(of: ",") == nil)
        {
            return;
        }
        
        switch status
        {
        case .needDate://输入日期，或到期天数，或金额，3位数判断为天数，4位数判断为日期，5位数以上判断为金额
            if(calcDays())
            {
                refreshScreen()
                status = .needRate
                labMain.text = details[1]
                labTip.text = rateTips[rateType]
            }
        case .needRate:
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
                status = .needMoney
                labTip.text = "票金额"
            }
            else
            {
                status = .end
                labTip.text = "买断价"
            }
        case .needMoney:
            money = Double(sMoneyHandle.formatMoney(labMain.text!, set: false))!
            if(money > 0) {
                refreshScreen()
                labTip.text = "余金额"
            }
            status = .end
        case .end:
            labDetail.text = ""
            labMain.text = details[0]
            labTip.text = "到期日"
        default:
            break
        }
    }
    
    func handlePanGesture(_ sender:UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        if(sender.state == .began) {
            beganAdddays = adddays
        }
        if(sender.state == .changed){
            if(endDate.daysSinceToday() > 0) {
                let changeAddDays = Int(translation.x / 10.0)
                adddays = beganAdddays + changeAddDays
                adddays = adddays < 0 ? 0 : adddays
                refreshScreen()
            }
        }
    }
    
}

