//
//  MBTExpenseEntryViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/26/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit
import Firebase

class MBTExpenseEntryViewController: UIViewController {
    
    var expensesCategoryTitle: String?
    var enteredDate: String?
    var expense: Expense?
    
    @IBOutlet weak var expensesEtryNavigationBar: UINavigationItem!
    @IBOutlet weak var savePageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var expenseTitleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var selectedDateTextField: UITextField!
    
    @IBOutlet weak var titleErrorMessageLabel: UILabel!
    @IBOutlet weak var amountErrorMessageLabel: UILabel!
    @IBOutlet weak var dateErrorMessageLabel: UILabel!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expensesEtryNavigationBar.title = expense == nil ? expensesCategoryTitle : "Edit"
        hideKeyboard()
        amountTextField.keyboardType = .NumberPad
        setDelegateToTextField()
        hideErrorMessage()
        setTextFieldDataForEdit()
    }
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        bottomLayoutConstraint.constant = 0
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                self.bottomLayoutConstraint.constant += keyboardHeight
            }
        }
    }
    func keyboardWillHide(sender: NSNotification) {
        
        self.bottomLayoutConstraint.constant = 0
    }
    
    func setTextFieldDataForEdit() {
        
        expenseTitleTextField.text = expense?.title
        amountTextField.text = expense?.amount
        descriptionTextView.text = expense?.fullDescription
        selectedDateTextField.text = expense?.expenseDate
        enteredDate = expense?.expenseDate
    }
    
    func hideErrorMessage() {
        titleErrorMessageLabel.hidden = true
        amountErrorMessageLabel.hidden = true
        dateErrorMessageLabel.hidden = true
    }
    
    func setDelegateToTextField() {
        expenseTitleTextField.delegate = self
        amountTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    @IBAction func didTapSaveButton(sender: UIButton) {
        
        hideErrorMessage()
        if expenseTitleTextField.text?.isEmpty == true {
            titleErrorMessageLabel.hidden = false
        }
        if amountTextField.text?.isEmpty == true {
            amountErrorMessageLabel.hidden = false
        }
        if enteredDate == nil {
            dateErrorMessageLabel.hidden = false
        }
        
        guard expenseTitleTextField.text?.isEmpty == false && amountTextField.text?.isEmpty == false &&  dateErrorMessageLabel.text?.isEmpty == false else {
            return
        }
        if let enteredDate = enteredDate {
            
            self.savePageActivityIndicator.startAnimating()
            let expensesEntery =  ["ExpensesHeading": expenseTitleTextField.text ?? "",
                                   "Date": enteredDate,
                                   "Amount": amountTextField.text ?? "",
                                   "Full Description": descriptionTextView.text ?? ""]
            
            var message: String?
            if expensesEtryNavigationBar.title == "Edit" {
                message = "Successfully Updated"
            }
            MBTFirebaseDataService.dataService.createNewExpensEntry(expensesCategoryTitle!, expensesEntery: expensesEntery,existingTitle: expense?.reference ?? nil)
            self.savePageActivityIndicator.stopAnimating()
            
            let alert = UIAlertController(title: "Success..👍👍", message: message ?? "Successfully Added", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func didTapDateButton(sender: UIButton) {
        
        view.endEditing(true)
        
        let datePopUpViewController = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewControllerWithIdentifier("date") as! MBTDatePopUpViewController
        datePopUpViewController.delegate = self
        performAnimatedViewTranslation(datePopUpViewController.view, direction: .Top, duration: 0.6)
        
        self.addChildViewController(datePopUpViewController)
        self.view.addSubview(datePopUpViewController.view)
        datePopUpViewController.didMoveToParentViewController(self)
        
    }
    
    @IBAction func didTapBackButton(sender: UIBarButtonItem) {
        self.transitioningDelegate = self
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MBTExpenseEntryViewController: MBTSetDateDelegate {
    
    func enteredDate(date: String) {
        selectedDateTextField.text = date
        enteredDate = date
    }
}

extension MBTExpenseEntryViewController: UITextFieldDelegate,UITextViewDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        hideErrorMessage()
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            if string.characters.count == 0 {
                return true
            }
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            return prospectiveText.isNumeric()
        }
        return true
    }
}

extension MBTExpenseEntryViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissViewController()
    }
}
