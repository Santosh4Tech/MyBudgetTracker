//
//  MBTSignUpViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/25/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit
import Firebase

class MBTSignUpViewController: UIViewController {
//MARK: - IBOutlets
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpActivityIndicator:
    UIActivityIndicatorView!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var userNameErrorMassegeLabel: UILabel!
    @IBOutlet weak var emailErrorMessageLabel: UILabel!
    @IBOutlet weak var passwordErrorMessageLabel: UILabel!
    @IBOutlet weak var cnfPasswordErrorMessageLabel: UILabel!
//MARK: - ViewController Life Cycle method
    override func viewDidLoad() {
        
        contentScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-64)
        transitioningDelegate = self
        setDelegateToTextField()
        hideKeyboard()
        hideErrorMessage()
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
//MARK: - Keyboard Handeling methods
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
    
    //MARK: - local Methods
    /**
    setting delegate to the textFields
    */
    private func setDelegateToTextField() {
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    func hideErrorMessage() {
        userNameErrorMassegeLabel.hidden = true
        emailErrorMessageLabel.hidden = true
        passwordErrorMessageLabel.hidden = true
        cnfPasswordErrorMessageLabel.hidden = true
    }
    
    //MARK: - IBOutlet methods
    @IBAction func didTapRgisterButton(sender: UIButton) {
        
        
        hideErrorMessage()
        let username = userNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if username == "" {
            userNameErrorMassegeLabel.hidden = false
        }
        if email == "" {
            emailErrorMessageLabel.hidden = false
        }
        if password == "" {
            passwordErrorMessageLabel.hidden = false
        }
        if confirmPasswordTextField.text == "" {
            cnfPasswordErrorMessageLabel.hidden = false
            return
        }
        guard password == confirmPasswordTextField.text else {
            cnfPasswordErrorMessageLabel.hidden = false
            return
        }
        
        guard username != "" && email != "" && password != "" else {
            return
        }
        view.userInteractionEnabled = false
        view.alpha = 0.5
        signUpActivityIndicator.startAnimating()
        
        MBTFirebaseDataService.dataService.baseReference.createUser(email, password: password, withValueCompletionBlock: { error, result in
            if error != nil {
                self.view.userInteractionEnabled = true
                self.view.alpha = 1.0
                self.signUpActivityIndicator.stopAnimating()
                // There was a problem.
                self.presentViewController(MBTAlertMessage().showAlert("Error!!", message: error.localizedDescription), animated: true, completion: nil)
                
            } else {
                
                // Create and Login the New User with authUser
                
                MBTFirebaseDataService.dataService.baseReference.authUser(email, password: password, withCompletionBlock: {
                    err, authData in
                    
                    let user =  ["provider": authData.provider!,
                        "email": email,
                        "username": username]
                    
                    // Seal the deal in DataService.swift.
                    
                    MBTFirebaseDataService.dataService.createNewAccount(authData.uid, user: user)
                })
                
                // Store the uid and user name for future access
                NSUserDefaults.standardUserDefaults().setValue(result ["uid"], forKey: "uid")
                
                self.view.alpha = 1.0
                self.signUpActivityIndicator.stopAnimating()
                let viewController = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewControllerWithIdentifier("expenditureDetail")
                self.presentViewController(viewController, animated: true, completion: nil)
            }
        })
        
    }
    
    @IBAction func didTapCancelButton(sender: UIBarButtonItem) {
        dismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension MBTSignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard textField == emailTextField else {
            return
        }
        if !validateEmail(emailTextField.text ?? "") {
            emailErrorMessageLabel.text = "* Please enter a valid email."
            emailErrorMessageLabel.hidden = false
        } else {
            emailErrorMessageLabel.hidden = true
        }
    }
}

extension MBTSignUpViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissViewController()
    }
}
