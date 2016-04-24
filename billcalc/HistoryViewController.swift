//
//  HistoryViewController.swift
//  billcalc
//
//  Created by xxing on 16/3/27.
//  Copyright © 2016年 xxing. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    //var rates:[Rate] = Rate.LoadAllData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sDatabase.rates = Rate.LoadAllData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func doClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return g_rates.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RateTableViewCell", forIndexPath: indexPath) as! RateTableViewCell
        let rate = g_rates[indexPath.row]
        let endDate = NSDate(timeIntervalSince1970: rate.endDate as! Double)
        cell.labMoney.text = sMoneyHandle.wanYuan(rate.money as! Double)
        cell.labBank.text = rate.bank as? String
        cell.labEndDate.text = endDate.format("MM月dd日")
        cell.labRate.text = String(format:"%.2f", g_rates[indexPath.row].rate as! Double)
        NSLog("data guid: %d", rate.guid as! Int)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete) {
            let rate = g_rates[indexPath.row]
            rate.deleteFromDB()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
}
