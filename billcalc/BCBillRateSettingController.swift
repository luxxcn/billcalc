//
//  BCBillRateSettingController.swift
//  billcalc
//
//  Created by 星 鲁 on 2017/7/2.
//  Copyright © 2017年 xxing. All rights reserved.
//

import UIKit
import CoreData

class BCBillRateSettingController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let headers = ["基准利率", "利率浮动、手续费"]
    let hideTextField = UITextField()
    let hideAdjustTxtField = UITextField()
    var keyboard:BMTBillInfoKeyboard?
    var adjustKeyboard:BCAdjustRateKeyboard?
    
    var vcQuotation:QuotationListController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.title = "利率设置"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        self.navigationItem.rightBarButtonItem = addButton
        
        hideTextField.isHidden = true
        self.tableView.addSubview(hideTextField)
        keyboard = BMTBillInfoKeyboard(textField: hideTextField, baseRate: true)
        hideTextField.inputView = keyboard
        
        hideAdjustTxtField.isHidden = true
        self.tableView.addSubview(hideAdjustTxtField)
        adjustKeyboard = BCAdjustRateKeyboard(textField: hideAdjustTxtField)
        hideAdjustTxtField.inputView = adjustKeyboard
        
        sLogic.adjustRateController?.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func add() {
        
        sLogic.addAdjustRate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        vcQuotation?.tableView.reloadData()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate Methods  仅 AdjustRate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        var delIndexPath = indexPath
        delIndexPath?.section = 1
        var addIndexPath = newIndexPath
        addIndexPath?.section = 1
        switch type {
        case .delete:
            tableView.deleteRows(at: [delIndexPath!], with: .fade)
        case .insert:
            tableView.insertRows(at: [addIndexPath!], with: .fade)
            
            hideTextField.resignFirstResponder()
            hideAdjustTxtField.resignFirstResponder()
        default:
            break
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return headers.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 0 {
            
            return 1
        }
        
        return sLogic.adjustRateCount()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return headers[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = indexPath.section == 0 ? "baseRateCellIdentifier" : "adjustRateCellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

         //Configure the cell...
        
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            
            let baseRateCell = cell as! BCBaseRateCell
            baseRateCell.keyboard = self.keyboard // 注意：不要造成无限引用
            self.keyboard?.rateCell = baseRateCell
            
            baseRateCell.baseRates = sLogic.baseRate
            
        } else {
            
            let adjustCell = cell as! BCAdjustRateCell
            let adjustRate = sLogic.getAdjustRate(at: indexPath.row)
            adjustCell.adjustRate = adjustRate
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            return 75
        } else {
            
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            self.hideTextField.becomeFirstResponder()
        } else if indexPath.section == 1 {
            
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BCBaseRateCell {
                
                cell.unselected()
            }
            let adjustRateCell = tableView.cellForRow(at: indexPath) as? BCAdjustRateCell
            self.adjustKeyboard?.adjustRateCell?.unselected()
            self.adjustKeyboard?.adjustRateCell = adjustRateCell
            adjustRateCell?.keyboard = self.adjustKeyboard
            self.adjustKeyboard?.select(rateType: sLogic.clickedAdjustRateTag)
            
            self.hideAdjustTxtField.becomeFirstResponder()
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return indexPath.section == 0 ? false : true
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            sLogic.deleteAdjustRate(at: indexPath.row)
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
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//        if segue.destination is QuotationListController {
//            
//            (segue.destination as! QuotationListController).tableView.reloadData()
//        }
//    }

}
