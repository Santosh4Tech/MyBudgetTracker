//
//  MBTAddNewExpenseCategoryViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 4/1/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class MBTAddNewExpenseCategoryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transitioningDelegate = self
        setDelegateToTextField()
        hideKeyboard()
    }

    private func setDelegateToTextField() {
        titleTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    @IBAction func didTapBackButton(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didTapAddButton(sender: UIButton) {
        
        guard titleTextField.text?.isEmpty == false else {
            errorMessageLabel.textColor = UIColor.redColor()
            errorMessageLabel.text = "* Please enter a Title."
            return
        }
        
        let categoryDescription = ["Description " : descriptionTextView.text ?? ""]
        MBTFirebaseDataService.dataService.addCatagory(titleTextField.text ?? "" , fullDescription: categoryDescription)
    
        dismissViewControllerAnimated(true, completion: nil)

    }



}

extension MBTAddNewExpenseCategoryViewController: UITextFieldDelegate,UITextViewDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (titleTextField.text?.characters.count > 10 ) {
            
            return false
        }

        
        return true
    }
}

extension MBTAddNewExpenseCategoryViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissViewController()
    }
}