//
//  EditProfileViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 5/7/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapChangePasswordButton(sender: UIButton) {
    }
    
    @IBAction func didTapChangeUserName(sender: UIButton) {
        var inputTextField: UITextField?
        
        let userName = UIAlertController(title: "Change User Name", message: "You have selected to change your User name.", preferredStyle: UIAlertControllerStyle.Alert)
        userName.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        userName.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let t = inputTextField?.text
            if t == "" {
                
                let alert = UIAlertController(title: "Error..!!", message: "User name shouldn't be blank.", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                    self.presentViewController(userName, animated: true, completion: nil)
                })
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                MBTFirebaseDataService.dataService.changeUserName(t!)
            }
            
        }))
        userName.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "New User Name"
            textField.clearButtonMode = .WhileEditing
            inputTextField = textField
        })
        
        presentViewController(userName, animated: true, completion: nil)
    }
    
    @IBAction func didTapDeleteAccountButton(sender: UIButton) {
        var inputTextField: UITextField?
        
        let userName = UIAlertController(title: "Delete Account", message: "You have selected to Delete your Account.", preferredStyle: UIAlertControllerStyle.Alert)
        
        userName.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        userName.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let t = inputTextField?.text ?? ""
            MBTFirebaseDataService.dataService.deleteAccount(UserInformation.sharedInstance.email ?? "", password: t, handler: { (error) -> Void in
                if let error = error {
                    let alert = UIAlertController(title: "Error..!!", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                        self.presentViewController(userName, animated: true, completion: nil)
                    })
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    //self.u
                }
            })
        }))
        userName.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Password"
            textField.clearButtonMode = .WhileEditing
            inputTextField = textField
        })
        
        presentViewController(userName, animated: true, completion: nil)
    }
    
    @IBAction func didTapCancelButton(sender: UIBarButtonItem) {
        
        self.transitioningDelegate = self
        dismissViewControllerAnimated(true, completion: nil)
    }
}
extension EditProfileViewController: UIViewControllerTransitioningDelegate{
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissViewController()
    }
}
