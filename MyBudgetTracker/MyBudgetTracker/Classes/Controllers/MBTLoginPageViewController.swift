//
//  MBTLoginPageViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/25/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit
import Firebase

/**
 *  Dedicated Structure for Alert message
 */
struct MBTAlertMessage {
    
    /**
     Convenience method for showing Alert message
     
     - parameter title:   title for the Alert
     - parameter message: description for alert
     
     - returns: instance UIAlertController
     */
    
    func showAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        return alert
    }
}


extension UIViewController {
    /**
     Hide the Keyboard when user tap on the screen except the text field
     */
    func hideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

class MBTLoginPageViewController: UIViewController {
    
//MARK: - IBOutlets
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInPageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailErrorMessageLabel: UILabel!
    @IBOutlet weak var passwordErrorMessageLabel: UILabel!
    
    @IBOutlet weak var blurView: UIVisualEffectView!

    private var gradientLayer: CAGradientLayer?
    
//MARK: - ViewController Life Cycle method
    override func viewDidLoad() {
        logInPageActivityIndicator.hidden = true
        hideErrorMessage()
        setDelegateToTextField()
        hideKeyboard()
        gradientLayer = UIView.getGradientViewWithFrame(view.frame)
//        if let gradientLayer = gradientLayer {
//            blurView.layer.insertSublayer(gradientLayer, atIndex: 0)
//        }
    }
    
//MARK: - utility methods
    
    /**
     set all text Field delegate to handle keboard
     */
    private func setDelegateToTextField() {
        emailIdTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func hideErrorMessage() {
        emailErrorMessageLabel.hidden = true
        passwordErrorMessageLabel.hidden = true
    }
//MARK: - IBOutlet method
    
    @IBAction func didTapLoginButton(sender: UIButton) {
        
        hideErrorMessage()
        let email = emailIdTextField.text
        let password = passwordTextField.text
        
        if email == "" {
            emailErrorMessageLabel.hidden = false
            
        }
        if password == "" {
            passwordErrorMessageLabel.hidden = false
        }
        guard email != "" && password != "" else {
            return
        }
        
        view.userInteractionEnabled = false
        logInPageActivityIndicator.startAnimating()
        view.alpha = 0.5
        
        // Login with the Firebase's authUser method
        
        MBTFirebaseDataService.dataService.baseReference.authUser(email, password: password, withCompletionBlock: { error, authData in
            
            if error != nil {
                self.view.userInteractionEnabled = true
                
                self.logInPageActivityIndicator.stopAnimating()
                self.presentViewController(MBTAlertMessage().showAlert("Error!!", message: error.localizedDescription), animated: true, completion: { self.view.alpha = 1.0
                })
            } else {
                
                // Be sure the correct uid and user name  is stored.
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                
                // Enter the expenditureDetail page
                MBTFirebaseDataService.dataService.getUserInfo()
                self.logInPageActivityIndicator.stopAnimating()
                let viewController = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewControllerWithIdentifier("expenditureDetail")
                self.presentViewController(viewController, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func didTapHomeButton(sender: UIBarButtonItem) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
        self.presentViewController(viewController, animated: true, completion: nil)
    }
}


extension MBTLoginPageViewController:UITextFieldDelegate {
    
    //MARK: - UITextFieldDelegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard textField == emailIdTextField else {
            return
        }
        
        if !(emailIdTextField.text ?? "").validateEmail() {
            emailErrorMessageLabel.text = "* Please enter a valid email."
            emailErrorMessageLabel.hidden = false
        } else {
            emailErrorMessageLabel.hidden = true
        }
    }
    
}

