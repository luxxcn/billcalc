//
//  AdjustRate.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/7/5.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit
import CoreData

@objc(AdjustRate)
class AdjustRate: NSManagedObject {
    
    @NSManaged var money:NSNumber?
    @NSManaged var rate:NSNumber?
    @NSManaged var charge:NSNumber?
    
}
