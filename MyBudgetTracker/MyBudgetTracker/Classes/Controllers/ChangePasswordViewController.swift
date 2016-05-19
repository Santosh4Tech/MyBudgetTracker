//
//  ChangePasswordViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 5/10/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var oldPasswordErrorMessageLabel: UILabel!
    @IBOutlet weak var newPasswordErrorMessageLabel: UILabel!
    @IBOutlet weak var confirmPasswordErrorMessageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        hideKeyboard()
        hideErrorMessage()
        setDelegateToTextField()
    }

    private func setDelegateToTextField() {
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
    }
    /**
     Hide all error message
     */
     private func hideErrorMessage() {
        oldPasswordErrorMessageLabel.hidden = true
        newPasswordErrorMessageLabel.hidden = true
        confirmPasswordErrorMessageLabel.hidden = true
    }
    
    @IBAction func didTapCancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapChangeButton(sender: UIButton) {
        hideErrorMessage()
        var isOK = true
        let oldPassword = oldPasswordTextField.text ?? ""
        let newPassword = newPasswordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        if oldPassword == "" {
            oldPasswordErrorMessageLabel.hidden = false
            isOK = false
        }
        if newPassword == "" {
            newPasswordErrorMessageLabel.hidden = false
            isOK = false
        }
        if confirmPassword == "" || confirmPassword != newPassword {
            confirmPasswordErrorMessageLabel.hidden = false
            isOK = false
        }
        
        guard isOK else {
            return
        }
        
        MBTFirebaseDataService.dataService.changePassword(oldPassword, newPassword: newPassword) { (error) -> Void in
            if let error = error {
                self.presentViewController(MBTAlertMessage().showAlert("Error!!", message: error.localizedDescription), animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error..!!", message: "Password successfully changed.", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
}

extension ChangePasswordViewController:UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissViewController()
    }
}

extension ChangePasswordViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}