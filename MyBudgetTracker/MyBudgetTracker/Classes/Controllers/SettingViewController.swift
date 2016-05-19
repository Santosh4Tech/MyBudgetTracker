//
//  SettingViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 5/2/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit


enum SortBy: String {
    case Date = "date"
    case Amount = "amount"
    case Title = "title"
    case None = ""
    
}
class SettingViewController: UIViewController {

    
    @IBOutlet weak var dateCheckBoxButton: UIButton!
    @IBOutlet weak var amountCheckBoxButton: UIButton!
    @IBOutlet weak var titleCheckBoxButton: UIButton!
    
    var selectedItem: SortBy?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self
        MBTFirebaseDataService.dataService.getSortingOrdertype { (sortByString) -> Void in
            self.selectedItem = SortBy(rawValue: sortByString)
            self.setImage("radioButton_selected")
        }
    }

    @IBAction func didTapBackButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapDateButton(sender: UIButton) {
        handleSelection(.Date)

    }
    
    @IBAction func didTapAmountButton(sender: UIButton) {
        handleSelection(.Amount)
    }
    
    @IBAction func didTapTitleButton(sender: UIButton) {
        handleSelection(.Title)
    }
    @IBAction func didTapSaveButton(sender: UIButton) {
        
        MBTFirebaseDataService.dataService.setSortingOrder(selectedItem?.rawValue ?? "")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleSelection(orderType: SortBy) {
        guard selectedItem != orderType else {
            setImage("radiobutton")
            selectedItem = nil
            return
        }
        setImage("radiobutton")
        selectedItem = orderType
        setImage("radioButton_selected")
    }
    
    func setImage(imageName: String) {
        if let selectedItem = selectedItem {
            switch(selectedItem) {
            case .Amount: amountCheckBoxButton.setImage(UIImage(named: imageName), forState: .Normal)
            case .Date: dateCheckBoxButton.setImage(UIImage(named: imageName), forState: .Normal)
            case .Title: titleCheckBoxButton.setImage(UIImage(named: imageName), forState: .Normal)
            case .None: return
            }
        }
    }
    
}

extension SettingViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissViewController()
    }
}
