//
//  ViewController.swift
//  billcalc
//
//  Created by xxing on 16/3/10.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var labDetail: UILabel!
    @IBOutlet weak var labMain: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var btnRateTypes: [UIButton]!
    @IBOutlet weak var viewResult: UIView!
    
    var labTip = UILabel()
    let calcLogic = CalcLogic()
    
    var beganAdddays:Int = 0
    
    var fontMedium = UIFont.systemFont(ofSize: 24.0, weight: 0.3)
    var fontLight = UIFont.systemFont(ofSize: 24.0, weight: -0.7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // 按钮点击时高亮
        for btn in buttons
        {
            btn.setBackgroundImage(imageWithColor(UIColor.gray),
                                   for: UIControlState.highlighted)
        }
        
        // 提示信息
        //let labTip = UILabel()
        let content = calcLogic.updateTipLabel()
        let attributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 20)]
        let txtSize = content.boundingRect(
            with: CGSize(width:100, height:100),
            options: NSStringDrawingOptions.truncatesLastVisibleLine,
            attributes: attributes,
            context: nil).size
        let frame = UIScreen.main.bounds
        labTip.layer.masksToBounds = true
        labTip.layer.cornerRadius = 5
        labTip.text = content as String
        labTip.textAlignment = .center
        labTip.backgroundColor = UIColor.gray
        labTip.textColor = UIColor.white
        labTip.frame = CGRect(x: frame.width - txtSize.width - 20, y: 3,
                              width: txtSize.width, height: txtSize.height)
        labMain.addSubview(labTip)
        
        let panGesture = UIPanGestureRecognizer(
            target: self, action:#selector(ViewController.handlePanGesture(_:)))
        /// TODO: 只设置显示区可以出发滑动，因为会影响点击按钮效果。
        self.viewResult.addGestureRecognizer(panGesture)
        refreshScreen(tag: 1001)
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
    
    func refreshScreen(tag: Int) {
        labMain.text = calcLogic.updateMainLabel(aString: labMain.text!,
                                                 tag: tag)
        labTip.text = calcLogic.updateTipLabel()
        labDetail.text = calcLogic.updateDetailLabel()
    }
    
    @IBAction func rateSelect(_ sender: UIButton) {
        
        calcLogic.rateType = RateType(rawValue: sender.tag)!
        
        for btn in btnRateTypes {
            if(btn.tag == calcLogic.rateType.rawValue) {
                btn.titleLabel?.font = fontMedium;
            } else {
                btn.titleLabel?.font = fontLight;
            }
        }
        
        labTip.text = calcLogic.updateTipLabel()
    }
    
    @IBAction func needMoney(_ sender: UIButton) {
        
        refreshScreen(tag: sender.tag)
        sender.titleLabel?.font = calcLogic.needMoney ? fontMedium : fontLight
    }

    @IBAction func clickNumber(_ sender: UIButton) {
        
        refreshScreen(tag: sender.tag)
    }

    @IBAction func doReset(_ sender: UIButton) {

        refreshScreen(tag: sender.tag)
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        
        refreshScreen(tag: sender.tag)
    }
    
    @IBAction func doOK(_ sender: UIButton) {
        
        refreshScreen(tag: sender.tag)
    }
    
    func handlePanGesture(_ sender:UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        if(sender.state == .began) {
            beganAdddays = calcLogic.adddays
        }
        if(sender.state == .changed){
            
            let changeAddDays = Int(translation.x / 10.0)
            var adddays = beganAdddays + changeAddDays
            
            adddays = adddays < 0 ? 0 : adddays
            labMain.text = calcLogic.set(adddays: adddays,
                                         mainString: labMain.text!)
            labDetail.text = calcLogic.updateDetailLabel()
        }
    }
    
}

