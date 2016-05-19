//
//  ExpenseCalculatorViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 5/3/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class ExpenseCalculatorViewController: UIViewController {

    @IBOutlet weak var selectTypeView: UIView!
    @IBOutlet weak var categoryListView: UIView!
    
    var isShown = true
    var dropDownView: UITableView?
    var dataSource = [String]()
    let typeArray = ["All Category","Individual Category"]
    var categoryList = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        MBTFirebaseDataService.dataService.getCategoryList { (categoryList) -> Void in
            self.categoryList = categoryList
        }
        //categoryListView.hidden = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func DidTapSelectButtton(sender: UIButton) {
        
        handleDropDown(typeArray,frameView:selectTypeView,height: 90)
  
    }
    @IBAction func didTapSelectCategoryButton(sender: UIButton) {
        
        handleDropDown(categoryList,frameView: categoryListView,height: 120)
        
    }
    
    func handleDropDown(dataSource: Array<String> ,frameView: UIView,height: CGFloat) {
        
        if isShown {
            dropDownView = NSBundle.mainBundle().loadNibNamed("CalculatorTableView", owner: self, options: nil)[0] as? UITableView
            if let v = dropDownView {
                self.dataSource = dataSource
                v.delegate = self
                v.dataSource = self
                v.registerNib(UINib(nibName: "ExpenseCalculatorCell", bundle: nil), forCellReuseIdentifier: "myCell")
                v.frame = CGRectMake(frameView.frame.origin.x , frameView.frame.origin.y+frameView.frame.height , frameView.frame.width, height)
                
                view?.addSubview(v)
                isShown = false
            }
        } else {
            isShown = true
            dropDownView?.removeFromSuperview()
        }
    }
    
    @IBAction func didTapBackButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension ExpenseCalculatorViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell") as? ExpenseCalculatorCell
        cell?.titleLabel.text = dataSource[indexPath.row]
        
        return cell ?? UITableViewCell()
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
    }
}
