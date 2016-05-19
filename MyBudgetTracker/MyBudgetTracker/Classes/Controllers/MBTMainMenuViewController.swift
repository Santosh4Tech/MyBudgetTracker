//
//  MBTMainMenuViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 4/16/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

struct MenuImage {
    
    func getImageName(title: String)->String {
        switch title {
        case "Home": return "Home_Icon"
        case "Setting": return "Setting_Icon"
        case "Add New Category": return "add_Category"
        case "Expense Calculator": return"calculator"
        case "Sign Out": return "logout"
        case "Account": return "user"
        default: return "NoImage"
        }
    }
}

class MBTMainMenuViewController: UIViewController {

    @IBOutlet weak var mainMenuTableView: UITableView!
    @IBOutlet weak var tapToDismissView: UIView!
    
    var transition = CustomAnimation()
    let menuArray = ["Home","Add New Category","Expense Calculator","Setting","Account","Sign Out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapRecognizer))
        tapToDismissView.addGestureRecognizer(tapGesture)
    }
    

    @IBAction func didTapHome(sender: UIBarButtonItem) {
        removeViewWithAnimation(view, direction: .Right)
    }

    func tapRecognizer() {
        
        removeViewWithAnimation(view, direction: .Right)
    }
    
    private func dismissView() {
        let direction = ViewTranslationDirection.Right
        let component = direction.getComponent()
        view.frame = CGRectMake(view.frame.origin.x - view.frame.width , view.frame.origin.y, view.frame.width, view.frame.height)
        
        self.view.transform = CGAffineTransformMakeTranslation(component.0, component.1)
        UIView.animateWithDuration(0.4, animations: {self.view.transform = CGAffineTransformMakeTranslation(0, 0)},
                                   completion: {(value: Bool) in
                                    self.view.removeFromSuperview()
                                    self.removeFromParentViewController()
        })
    }
}

extension MBTMainMenuViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifire:String =  indexPath.row == 0 ? "userInfo" : "otherCells"
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifire, forIndexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifire, forIndexPath: indexPath) as! NavigationDrawerCell
            cell.configureCell(menuArray[indexPath.row-1], icon: MenuImage().getImageName(menuArray[indexPath.row-1]))
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 ? view.frame.height/6 : view.frame.height/10
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 {
            menuItemSelected(indexPath.row)
        }
    }
    
}

private extension MBTMainMenuViewController {
    
    func menuItemSelected(index:Int){
        switch index {
        case 1: backToHome()
            
        case 2: newCategory()
            
        case 3: expenseCalculator()
        case 4: setting()
        case 5: accountSetting()
        case 6: signOut()
        default : print("")
        }
        
    }
    
    //AccountSetting
    func backToHome() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func newCategory() {
        let newCategoryViewController = UIStoryboard(name: "Expenses", bundle:nil).instantiateViewControllerWithIdentifier("newCategory") as? MBTAddNewExpenseCategoryViewController
        if let newCategoryViewController = newCategoryViewController {
            transition.direction = .Bottom
            transition.duration = 0.3
            newCategoryViewController.transitioningDelegate = self
            presentViewController(newCategoryViewController, animated: true, completion: nil)
        }
        

    }
    
    func accountSetting() {
        
        
        let accountSettingViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("AccountSetting") as? EditProfileViewController
        if let vc = accountSettingViewController {
            transition.direction = .Bottom
            transition.duration = 0.3
            vc.transitioningDelegate = self
            presentViewController(vc, animated: true, completion: nil)
        }
        
    }
    
    func signOut() {
        // unauth() is the logout method for the current user.
        
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to Sign Out ?", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            MBTFirebaseDataService.dataService.currentUserReference.unauth()
            
            // Remove the user's uid from storage.
            
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "userName")
            
            // Head back to Login!
            
            let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loginPage")
    
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
        alert.addAction(action)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    func setting() {
        let settingViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("setting") as? SettingViewController
        
        if let settingViewController = settingViewController {
            transition.direction = .Bottom
            transition.duration = 0.3
            settingViewController.transitioningDelegate = self
            presentViewController(settingViewController, animated: true, completion: nil)
        }
    }
    
    func expenseCalculator() {
        //expenseCalculator
        let expenseCalculatorViewController = UIStoryboard(name: "Update", bundle:nil).instantiateViewControllerWithIdentifier("expenseCalculator") as? ExpenseCalculatorViewController
        
        if let expenseCalculatorViewController = expenseCalculatorViewController {
            transition.direction = .Bottom
            transition.duration = 0.3
            expenseCalculatorViewController.transitioningDelegate = self
            presentViewController(expenseCalculatorViewController, animated: true, completion: nil)
        }
    }
    
}

extension MBTMainMenuViewController: UIViewControllerTransitioningDelegate{
    
func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    return transition
    }
}