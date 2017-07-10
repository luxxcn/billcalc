//
//  QuotationLogic.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/6/16.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit
import CoreData

let sLogic = QuotationLogic()

class QuotationLogic {
    
    var _baseRateController:NSFetchedResultsController<NSFetchRequestResult>?
    var baseRateController:NSFetchedResultsController<NSFetchRequestResult>? {
        get {
            if _baseRateController != nil {
                return _baseRateController
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = appDelegate.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "BaseRate", in: managedObjectContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
            
            request.entity = entity
            request.fetchBatchSize = 20
            
            let sortDescriptor0 = NSSortDescriptor(key: "date", ascending: true)
            //let sortDescriptor1 = NSSortDescriptor(key: "type", ascending: true)
            request.sortDescriptors = [sortDescriptor0]
            
            _baseRateController =
                NSFetchedResultsController(fetchRequest: request,
                                           managedObjectContext: managedObjectContext,
                                           sectionNameKeyPath: nil,
                                           cacheName: nil)
            
            //_baseRateController?.delegate = self
            
            do {
                try _baseRateController?.performFetch()
            } catch {
                
                print(error.localizedDescription)
            }
            
            return _baseRateController
        }
    }
    var baseRate:BaseRate? {
        
        get {
            
            if (baseRateController?.fetchedObjects?.count)! > 0 {
                
                let indexPath = IndexPath(row: 0, section: 0)
                return baseRateController?.object(at: indexPath) as? BaseRate
            }
            let context = baseRateController?.managedObjectContext
            let entity = baseRateController?.fetchRequest.entity
            let baseRate = NSEntityDescription.insertNewObject(forEntityName: (entity?.name)!, into: context!) as? BaseRate
            baseRate?.date = 1
            baseRate?.rateData = "0,0,0,0,0,0"
            return baseRate
        }
    }
    
    var _adjustRateController:NSFetchedResultsController<NSFetchRequestResult>?
    var adjustRateController:NSFetchedResultsController<NSFetchRequestResult>? {
        get {
            if _adjustRateController != nil {
                return _adjustRateController
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = appDelegate.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "AdjustRate", in: managedObjectContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
            
            request.entity = entity
            request.fetchBatchSize = 20
            
            let sortDescriptor0 = NSSortDescriptor(key: "money", ascending: false)
            request.sortDescriptors = [sortDescriptor0]
            
            _adjustRateController =
                NSFetchedResultsController(fetchRequest: request,
                                           managedObjectContext: managedObjectContext,
                                           sectionNameKeyPath: nil,
                                           cacheName: nil)
            
            do {
                try _adjustRateController?.performFetch()
            } catch {
                
                print(error.localizedDescription)
            }
            
            return _adjustRateController
        }
    }
    
    var bills = [Bill]()
    var tableView:UITableView?
    
    var currSelected:IndexPath?
    
    var totalMoney:Double {// 单位  元
        
        get {
            
            var sum = 0.0
            for bill in bills {
                
                sum += Double(bill.money)!
            }
            
            return sum * 10000
        }
    }
    
    var totalPay:Double {
        
        get {
            
            var sum = 0.0
            for bill in bills {
                
                let pay = Double(bill.money)! * bill.price * 100
                sum += pay
            }
            
            return sum
        }
    }
    let formatter = NumberFormatter()
    
    var totalText:String {
        
        get {
            
            if bills.count == 0 {
                
                return ""
            }
            
            //print(sNumberHelper.formatAmountCN(NSNumber(value: totalMoney))!)
            
            return String(format: "共%d张，%@元", bills.count,
                          sNumberHelper.formatNumber(NSNumber(value: totalMoney))!)
        }
    }
    
    var payTotalText:String {
        
        get {
            
            if bills.count == 0 {
                
                return ""
            }
            
            let pay = totalPay
            return String(format: "扣息%@元，余%@元",
                          formatter.string(from: NSNumber(value: pay))!,
                          formatter.string(from: NSNumber(value: totalMoney - pay))!)
        }
    }
    
    var clickedAdjustRateTag = AdjustRateType.adjustBaseMoney
    
    init() {
        formatter.numberStyle = .decimal
    }
    
    // MARK: adjust rate handler
    func adjustRateCount() -> Int {
        
        return (adjustRateController?.fetchedObjects?.count)!
    }
    
    func addAdjustRate() {
        
        let context = adjustRateController?.managedObjectContext
        let entity = adjustRateController?.fetchRequest.entity
        let adjustRate = NSEntityDescription.insertNewObject(
            forEntityName: (entity?.name)!, into: context!) as? AdjustRate
        adjustRate?.money = 0.0
        adjustRate?.charge = 0.0
        adjustRate?.rate = 0.0
        do {
            
            try adjustRate?.managedObjectContext?.save()
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    func deleteAdjustRate(at row: Int) {
        
        let indexPath = IndexPath(row: row, section: 0)
        let adjustRate = adjustRateController?.object(at: indexPath)
        let context = adjustRateController?.managedObjectContext
        context?.delete(adjustRate as! NSManagedObject)
        do {
            
            try context?.save()
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    func getAdjustRate(at row: Int) -> AdjustRate {
        
        let indexPath = IndexPath(row: row, section: 0)
        return adjustRateController?.object(at: indexPath) as! AdjustRate
    }
    
    func allAdjustRate() -> [AdjustRate]? {
        
        return adjustRateController?.fetchedObjects as? [AdjustRate]
    }
    
    func getRightAdjustRate(money: Double) -> AdjustRate? {
        
        var rate:AdjustRate?
        for adjustRate in allAdjustRate()! {
            
            if money >= Double(adjustRate.money!) {
                
                rate = adjustRate
                break
            }
        }
        
        return rate
    }
    
    // MARK: bill handler
    
    func count() -> Int {
        
        return bills.count
    }
    
    func addBill() {
        
        let bill = Bill()
        bills.append(bill)
        tableView?.reloadData()
    }
    
    func removeAll() {
        
        bills.removeAll()
        tableView?.reloadData()
    }
    
    func bill(at indexPath: IndexPath) -> Bill {
        
        return bills[indexPath.row]
    }
    
    func selectedBill() -> Bill {
        
        return bill(at: self.currSelected!)
    }
    
    func selectedBankType() -> BankType {
        
        let bill = selectedBill()
        return bill.bankType
    }
    
    func updateTableViewRow() {
        
        tableView?.beginUpdates()
        tableView?.reloadRows(at: [self.currSelected!], with: .none)
        tableView?.endUpdates()
    }
    
    func deleteBill(at indexPath: IndexPath) {
        
        self.bills.remove(at: indexPath.row)
        self.tableView?.deleteRows(at: [indexPath], with: .fade)
    }
    
    func reloadData() {
        
        tableView?.reloadData()
    }
    
    func updateBill(addMoney:String) {
        
        let bill = selectedBill()
        
        if bill.money == "0.00" {
            
            if addMoney == "." {
                
                bill.money = "0."
            } else if addMoney != "00" {
                
                bill.money = addMoney
            }
        } else {
            
            let range = bill.money.range(of: ".")
            if addMoney != "." || range == nil {
            
                if bill.money == "0" && addMoney != "." {
                    
                    bill.money = addMoney
                } else {
                    
                    bill.money.append(addMoney)
                }
            }
        }
        
//        let range = bill.money.range(of: ".")
//        if range != nil {
//            
//            //小数部分不超过两位?
//        }
        
        updateTableViewRow()
    }
    
    func backspaceMoney() {
        
        let bill = selectedBill()
        if bill.money.characters.count > 0 {
            
            
            repeat {
                
                let index = bill.money.index(bill.money.endIndex, offsetBy: -1)
                bill.money = bill.money.substring(to: index)
            } while bill.money.range(of: ".")?.upperBound == bill.money.endIndex
            
            if bill.money == "" {
                bill.money = "0"
            }
        
            updateTableViewRow()
        }
    }
    
    func updateBill(bankType:BankType) {
        
        let bill = selectedBill()
        bill.bankType = bankType
        
        updateTableViewRow()
    }
    
    func updateBill(endDate num: String) {
        
        if num == "." || num == "00" {
            return
        }
        
        let bill = selectedBill()
        switch bill.dateStep {
        case .month0:
            if num != "0" && num != "1" {
                
                bill.month[0] = "0"
                bill.month[1] = num
                bill.day[0] = "_"
                bill.dateStep = .day0
            } else {
                
                bill.month[0] = num
                bill.month[1] = "_"
                bill.dateStep = .month1
            }
        case .month1:
            
            if bill.month[0] != "1" || Int(num)! <= 2 {
                
                bill.month[1] = num
                bill.day[0] = "_"
                bill.dateStep = .day0
            } else {
                // TODO: ALERT
                return
            }
        case .day0:
            
            if Int(num)! > 3 {
                
                bill.day[0] = "0"
                bill.day[1] = num
                bill.dateStep = .month0
            } else {
                bill.day[0] = num
                bill.day[1] = "_"
                bill.dateStep = .day1
            }
        case .day1:
            
            let comps = Date().components()
            let month = Int(String(format: "%@%@", bill.month[0], bill.month[1]))!
            let day = Int(String(format: "%@%@", bill.day[0], num))!
            var year = comps.year!
            
            if month < comps.month! || (month == comps.month! && day <= comps.day!) {
                
                year += 1
            }
            
            let date = sDateTimeHandle.createDate(year: year, month: month, day: day)
            
            if date == nil {
                
                //TODO: alert error date
                return
            }
            
            bill.day[1] = num
            bill.dateStep = .month0
        }
        
        //TODO： 日期错误则重新输入？
        
        updateTableViewRow()
    }
    
    func backspaceDate() {
        
        let bill = selectedBill()
        
        if bill.day[1] != "_" {
            
            bill.day[1] = "_"
            bill.dateStep = .day1
        } else if bill.day[0] != "_" {
            
            bill.day[0] = "_"
            bill.dateStep = .day0
        } else if bill.month[1] != "_" {
            
            bill.month[1] = "_"
            bill.dateStep = .month1
        } else if bill.month[0] != "_" {
            
            bill.month[0] = "_"
            bill.dateStep = .month0
        } else {
            
            return
        }
        
        updateTableViewRow()
    }
    
    func selectBill(up: Bool) {
        
        if self.currSelected != nil {
            
            let adjust = up ? -1 : 1
            let row = (self.currSelected?.row)! + adjust
            if row >= 0 && row < (self.tableView?.numberOfRows(inSection: (self.currSelected?.section)!))! {
                
                self.currSelected?.row = row
                self.tableView?.reloadData()
            } else if row == count() {
                
                self.currSelected?.row = row
                addBill()
            }
            
            if self.currSelected != nil {
                
                let position:UITableViewScrollPosition = up ? .top : .bottom
                self.tableView?.scrollToRow(at: self.currSelected!, at: position, animated: true)
            }
        }
    }
    
    func adjustPrice(add: Bool) {
        
        let bill = selectedBill()
        
        if add {
            
            bill.priceAdd += 0.01
        } else {
            
            bill.priceAdd -= 0.01
        }
        
        updateTableViewRow()
    }
}
