//
//  MBTDatePopUpViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/31/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

/**
 *  Conform this protocol to get the Date from DatePicker
 */
protocol MBTSetDateDelegate: NSObjectProtocol {
    
    func enteredDate(date: String)
}

/// Handle DatePicker Event
class MBTDatePopUpViewController: UIViewController {

    weak var delegate: MBTSetDateDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerContentView: UIView!
    
    var dateString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = .Date
        datePickerContentView.layer.cornerRadius = 7.0
        datePickerContentView.layer.masksToBounds = true
        
    }

    @IBAction func didTapOkButton(sender: UIButton) {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        dateString = formatter.stringFromDate(datePicker.date)
        if let delegate = delegate {
            delegate.enteredDate(dateString!)
        }
        removeViewWithAnimation(view, direction: .Bottom)
    }

    @IBAction func didTapCancelButton(sender: UIButton) {
        removeViewWithAnimation(view, direction: .Bottom)
    }
}
