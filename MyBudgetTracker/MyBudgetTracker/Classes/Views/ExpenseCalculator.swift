//
//  ExpenseCalculator.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 5/3/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class ExpenseCalculator: UITableView,UITableViewDataSource,UITableViewDelegate {

 
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell")
        
        return cell!
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
    }
}
