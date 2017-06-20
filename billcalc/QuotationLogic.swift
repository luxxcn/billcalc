//
//  QuotationLogic.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/6/16.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

let sLogic = QuotationLogic()

class QuotationLogic: NSObject {
    
    var bills = [Bill]()
    var tableView:UITableView?
    
    var currSelected:IndexPath?
    
    func count() -> Int {
        
        return bills.count
    }
    
    func addBill() {
        
        let bill = Bill()
        bills.append(bill)
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
        
        if Double(bill.money) == 0.0 {
            
            if addMoney == "." {
                
                bill.money = "0."
            } else if addMoney != "00" {
                
                bill.money = addMoney
            }
        } else {
            
            let range = bill.money.range(of: ".")
            if addMoney != "." || range == nil {
                
                bill.money.append(addMoney)
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
            
            let index = bill.money.index(bill.money.endIndex, offsetBy: -1)
            bill.money = bill.money.substring(to: index)
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
                if self.currSelected != nil {
                    
                    self.tableView?.scrollToRow(at: self.currSelected!, at: .bottom, animated: true)
                }
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
