//
//  MBTRenameViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 4/17/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit
import Firebase

class MBTRenameViewController: UIViewController {
    
    @IBOutlet weak var oldNameTextField: UITextField!
    @IBOutlet weak var newTitleTextField: UITextField!
    
    @IBOutlet weak var titleErrorMessageLabel: UILabel!
    
    var selectedCategoryName: String?
    var categoryList = [String]()
    var expenseList = [Expense]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldNameTextField.text = selectedCategoryName ?? ""
        hideKeyboard()
        newTitleTextField.delegate = self
        titleErrorMessageLabel.hidden = true
        
    }
    
    @IBAction func didTapRenameButton(sender: UIButton) {
        
        titleErrorMessageLabel.hidden = true
        
        guard let newTitle = newTitleTextField.text where newTitleTextField.text != "" else {
            titleErrorMessageLabel.hidden = false
            return
        }
        
        for category in categoryList {
            if category.uppercaseString == newTitle.uppercaseString {
                presentViewController(MBTAlertMessage().showAlert("Oops..!!", message: "Category already Exist"), animated: true, completion: nil)
                return
            }
        }
        MBTFirebaseDataService.dataService.renameCategory(newTitleTextField.text!, oldTitle: oldNameTextField.text!)
        
        let alert = UIAlertController(title: "Success..", message: "Successfully renamed.", preferredStyle: UIAlertControllerStyle.Alert)
        let action  = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)

    }
    
    @IBAction func didTapBackButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension MBTRenameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (newTitleTextField.text?.characters.count > 10 )
        {
            
            return false
        }
        
        return true
    }
}
