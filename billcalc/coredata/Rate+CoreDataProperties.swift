//
//  Rate+CoreDataProperties.swift
//  billcalc
//
//  Created by xxing on 16/3/18.
//  Copyright © 2016年 xxing. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Rate {

    @NSManaged var adddays: NSNumber?
    @NSManaged var bank: NSString?
    @NSManaged var date: NSNumber?
    @NSManaged var endDate: NSNumber?
    @NSManaged var guid: NSNumber?
    @NSManaged var money: NSNumber?
    @NSManaged var monthRate: NSNumber?
    @NSManaged var rate: NSNumber? // 之所以要保存rate是为了方便动态调整价格
}
