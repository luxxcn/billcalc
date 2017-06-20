//
//  QuotationListController.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/6/11.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit

class QuotationListController: UITableViewController {
    
    let hideTextField = UITextField()// 仅仅用于弹出键盘
    var billInfoKeyboard:BMTBillInfoKeyboard?
    var touchedMoney = true
    //let logic = QuotationLogic()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        billInfoKeyboard = BMTBillInfoKeyboard(textField: self.hideTextField)
        let keyboardHeader = BMTKeyboardHeader(textField: self.hideTextField)
        self.hideTextField.inputView = self.billInfoKeyboard
        self.hideTextField.inputAccessoryView = keyboardHeader
        self.tableView.addSubview(hideTextField)
        
        sLogic.tableView = self.tableView
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBill))
        self.navigationItem.rightBarButtonItem  = addButton
        self.navigationItem.title = "报价表"
        self.navigationItem.backBarButtonItem?.title = "<"
        
        let settingButton = UIButton(frame: CGRect(x: 5, y: 1, width: 75, height: 35))
        settingButton.setTitle("设置利率", for: .normal)
        settingButton.setTitleColor(sColorHelper.colorFrom(hex: 0x007aff), for: .normal)
        settingButton.titleLabel?.font = UIFont.systemFont(
            ofSize: 14, weight: UIFontWeightUltraLight)
        settingButton.addTarget(self, action: #selector(clickedSettingButton), for: .touchUpInside)
        keyboardHeader.addSubview(settingButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickedSettingButton() {
        
        self.performSegue(withIdentifier: "showSettingRateViewSegue", sender: self)
        self.hideTextField.resignFirstResponder()
    }
    
    func addBill() {
        
        sLogic.addBill()
        let indexPath = IndexPath(row: sLogic.count() - 1, section: 0)
        self.tableView(tableView, didSelectRowAt: indexPath)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sLogic.count()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "BillPriceCellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as! BCBillPriceCell

        // Configure the cell...
        cell.controller = self
        let bill = sLogic.bill(at: indexPath)
        cell.labMoney.text = String(format: "%@万", bill.money)
        cell.labBankType.text = bill.bankType.value
        //cell.labEndDate.text = Date(timeIntervalSince1970: bill.endDate).format("MM-dd")
        cell.labEndDate.text = String(format: "%@%@-%@%@", bill.month[0], bill.month[1], bill.day[0], bill.day[1])
        if bill.daysSinceToday > 0 {
            
            cell.labEndDate.text?.append(String(format: "(%d天)", bill.daysSinceToday))
        }
        cell.labPrice.text = String(format: "%.2f%%", bill.price)
        
        if indexPath == sLogic.currSelected {
            
            cell.contentView.backgroundColor = sColorHelper.colorFrom(hex: 0xdcdcdc)
        } else {
            
            cell.contentView.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        hideTextField.becomeFirstResponder()
        self.billInfoKeyboard?.selectRow(at: indexPath, touchedMoney: touchedMoney)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            sLogic.deleteBill(at: indexPath)
            
            if indexPath == sLogic.currSelected {
                
                self.hideTextField.resignFirstResponder()
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.destination is BCBillBaseRateController {
            
            (segue.destination as! BCBillBaseRateController).vcQuotation = self
        }
    }

}
