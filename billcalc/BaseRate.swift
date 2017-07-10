//
//  BaseRate.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/7/4.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit
import CoreData

@objc(BaseRate)
class BaseRate: NSManagedObject {
    
    @NSManaged var date:NSNumber?
    @NSManaged var rateData:String?
    
    var rates:[String]? {
        
        get {
            
            return rateData?.characters.split(separator: ",").map(String.init)
        }
        
        set {
            
            rateData = newValue?.map{String($0)}.joined(separator: ",")
        }
    }
    
    subscript(row: Int) -> String? {
    
        return rates?[row]
    }
}
