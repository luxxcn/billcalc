//
//  File.swift
//  billcalc
//
//  Created by xxing on 16/3/18.
//  Copyright © 2016年 xxing. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let sDatabase = Database()

class Database: NSObject {
    
    static let sDatabase = Database()
    
    // 使用 apDelegate
    func context()->NSManagedObjectContext{
        return (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    }
    
    func save() {
        do {
            try context().save()
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }
    }
    
    /*func loadDataForEntity(_ entity:String, predicate:String)->[AnyObject]{
        var result = [AnyObject]()
    
        let request = NSFetchRequest(entityName: entity)
        request.predicate = NSPredicate(format: predicate)
        //request.sortDescriptors?.append(NSSortDescriptor(key: "rate", ascending: true))
        
        do {
            result = try context().fetch(request)
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }
        
        return result
    }
 */
}
