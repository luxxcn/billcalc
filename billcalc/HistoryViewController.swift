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
    @IBAction func doClose(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return g_rates.count
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RateTableViewCell", for: indexPath) as! RateTableViewCell
//        let rate = g_rates[(indexPath as NSIndexPath).row]
//        let endDate = Date(timeIntervalSince1970: rate.endDate as! Double)
//        cell.labMoney.text = sMoneyHandle.wanYuan(rate.money as! Double)
//        cell.labBank.text = rate.bank as? String
//        cell.labEndDate.text = endDate.format("MM月dd日")
//        cell.labRate.text = String(format:"%.2f", g_rates[(indexPath as NSIndexPath).row].rate as! Double)
//        NSLog("data guid: %d", rate.guid as! Int)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {
//            let rate = g_rates[(indexPath as NSIndexPath).row]
//            rate.deleteFromDB()
//            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
 
}
