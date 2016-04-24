//
//  Rate.swift
//  billcalc
//
//  Created by xxing on 16/3/18.
//  Copyright © 2016年 xxing. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var g_rates:[Rate] = Rate.LoadAllData()

@objc(Rate) class Rate: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    init()
    {
        let context = sDatabase.context()
        let entity = NSEntityDescription.entityForName("Rate", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    func saveToDB() {
        sDatabase.save()
        //g_rates.append(self)
    }
    
    func deleteFromDB() {
        sDatabase.context().deleteObject(self)
        sDatabase.save()
        for i in 0...g_rates.count - 1
        {
            if(g_rates[i].guid == self.guid)
            {
                g_rates.removeAtIndex(i)
                break
            }
        }
    }
    
    class func GetRateByGuid(guid:Int)->Rate? {
        let predicate = String(format: "guid = %d", guid)
        let results = sDatabase.loadDataForEntity("Rate", predicate: predicate)
        return results.count > 0 ? results[0] as? Rate : nil
    }
    
    // 读取所有数据
    class func LoadAllData()->[Rate] {
        return sDatabase.loadDataForEntity("Rate", predicate: "rate > 0.0") as! [Rate]
    }
}
