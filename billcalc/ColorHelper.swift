//
//  ColorHelper.swift
//  BillMaster2
//
//  Created by 星 鲁 on 2016/12/27.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit

let sColorHelper = ColorHelper()

class ColorHelper: NSObject {
    
    /// 用 0x878787 生成颜色
    func colorFrom(hex: UInt32) -> UIColor {
        
        let red = Float((hex >> 16) & 0xFF) / 255.0
        let green = Float((hex >> 8) & 0xFF) / 255.0
        let blue = Float(hex & 0xFF) / 255.0
        
        return UIColor(red: CGFloat(red),
                       green: CGFloat(green),
                       blue: CGFloat(blue),
                       alpha: 1.0)
    }
    
    /// 生成颜色图片
    func imageFrom(color: UIColor) -> UIImage {
        let rect:CGRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageFrom(hex: UInt32) -> UIImage {
        
        return self.imageFrom(color: self.colorFrom(hex: hex))
    }
}
