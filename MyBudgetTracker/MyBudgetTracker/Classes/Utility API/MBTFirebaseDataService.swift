//
//  MBTFirebaseDataService.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/25/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit
import Firebase

/// Convenience class to intract with Firebase
class MBTFirebaseDataService: NSObject {
    
    static let dataService = MBTFirebaseDataService()
    
    //MARK: - Private properties
    
    private var baseRef = Firebase(url: "\(BASE_URL)")
    private var  userRef = Firebase(url: "\(BASE_URL)/users")
    private var barItemRef = Firebase(url: "\(BASE_URL)/menuBarItems")
    
    //MARK: - Local propertis
    
    var baseReference: Firebase {
        return baseRef
    }
    
    var allUserReference: Firebase {
        return userRef
    }
    
    var currentUserReference: Firebase {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        
        let currentUser = Firebase(url: "\(baseReference)").childByAppendingPath("users").childByAppendingPath(userID)
        return currentUser!
    }
    
    var barItemreference: Firebase {
        return barItemRef
    }
    
    var expensesreference: Firebase {
        let expensesRef = currentUserReference.childByAppendingPath("Expenses")
        return expensesRef
    }
    
    var customCategoryreference: Firebase {
        let expensesRef = currentUserReference.childByAppendingPath("CustomCategory")
        return expensesRef
    }
    
    private override init() {
    }
    //MARK: - Firebase Opertional methods
    
    /**
     Creates  a new User
     
     - parameter uid:  uid
     - parameter user: user info
     */
    
    func createNewAccount(uid: String, user: Dictionary<String, String>) {
        
        // A User is born.
        allUserReference.childByAppendingPath(uid).setValue(user)
    }
    
    /**
     Convenience Method for inserting new entry under a particular Category
     
     - parameter expensesCategoryTitle: category title
     - parameter expensesEntery:        expenses description
     */
    
    func createNewExpensEntry(expensesCategoryTitle: String, expensesEntery: Dictionary<String,String>, existingTitle: String?) {
        
        // New expenses Entry
        let dateFormater = NSDateFormatter()
        dateFormater.dateStyle = .MediumStyle
        dateFormater.timeStyle = .MediumStyle
        let currentTimeWithDate = dateFormater.stringFromDate(NSDate())
        expensesreference.childByAppendingPath(expensesCategoryTitle).childByAppendingPath(String(existingTitle ?? currentTimeWithDate)).setValue(expensesEntery)
        
    }
    
    /**
     Convenience Method for creating a new category of expenses
     
     - parameter title:           title
     - parameter fullDescription: description about the Category
     */
    func addCatagory(title: String,fullDescription: Dictionary<String,String>) {
        customCategoryreference.childByAppendingPath(title).setValue(fullDescription)
    }
    
    /**
     Convenience Method for fetching all the categories from firebase
     
     - parameter completionHandler: send a list of category
     */
    
    func getCategoryList(completionHandler: ((Array<String>)->Void)) {
        
        var menuBarItems = [String]()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            self.barItemreference.observeEventType( .Value) { (snapshot: FDataSnapshot!) -> Void in
                menuBarItems.removeAll()
                var fixedCategoryArray = [String]()
                for item in snapshot.children {
                    let item = item as! FDataSnapshot
                    fixedCategoryArray.append(item.key)
                }
                self.customCategoryreference.observeEventType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                    menuBarItems.removeAll()
                    var customCatagory = [String]()
                    for item in snapshot.children {
                        let item = item as! FDataSnapshot
                        customCatagory.append(item.key)
                    }
                    menuBarItems = fixedCategoryArray + customCatagory
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(menuBarItems)
                    })
                })
                
            }
        }
    }
    
    /**
     Convenience Method for fetching expenses under a particular Category
     
     - parameter category:          the required
     - parameter completionHandler: will return a array of expense under a particular Category
     */
    func getExpense(category: String, completionHandler:((Array<Expense>)->Void)) {
        
        var expenseList = [Expense]()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            self.expensesreference.childByAppendingPath(category).observeEventType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                expenseList.removeAll()
                for item in snapshot.children  {
                    let item = item as! FDataSnapshot
                    var descriptionTempArray = [String]()
                    for child in item.children {
                        let child = child as! FDataSnapshot
                        
                        descriptionTempArray.append(child.value as! String)
                    }
                    let reference = item.key
                    let expenses = Expense(briefHeader: descriptionTempArray[2] , amount: descriptionTempArray[0],expenseDate:descriptionTempArray[1] , fullDescription: descriptionTempArray[3], reference: reference)
                    expenseList.append(expenses)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completionHandler(expenseList)
                })
            })
        }
    }
    
    /**
     Convenience Method to rename a Category
     
     - parameter newTitle: newTitle
     - parameter oldTitle: oldTitle
     */
    func renameCategory(newTitle: String, oldTitle: String ) {
        
        var isUpdating = true
        let ref = expensesreference.childByAppendingPath(newTitle)
        getExpense(oldTitle) { (expenseList) -> Void in
            for item in expenseList where isUpdating {
                let expensesEntery =  ["ExpensesHeading": item.title ?? "",
                    "Date": item.expenseDate ?? "",
                    "Amount": item.amount ?? "",
                    "Full Description": item.fullDescription ?? ""]
                ref.childByAppendingPath(item.reference).setValue(expensesEntery)
            }
            if isUpdating {
                isUpdating = false
                MBTFirebaseDataService.dataService.addCatagory(newTitle, fullDescription: ["Description ":""])
                MBTFirebaseDataService.dataService.customCategoryreference.childByAppendingPath(oldTitle).removeValue()
                self.removeOldData(oldTitle)
            }
            
        }
        
    }
    
    /**
     Will store sorting_order of user in Firebase
     
     - parameter order: sorting_order selected by user
     */
    
    func setSortingOrder(order: String){
        currentUserReference.childByAppendingPath("sortingOrder").setValue(order)
        
    }
    
    /**
     Will retrive sorting_order of user from Firebase
     
     - parameter completionHandler: It will execute after retrive sorting_order from Firebase
     */
    func getSortingOrdertype(completionHandler: ((String)->Void)) {
        currentUserReference.childByAppendingPath("sortingOrder").observeEventType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            let temp = snapshot.value
            let sortBy = temp as? String
           completionHandler(sortBy ?? "")
        }
        
    }
    /**
     Will fetch User Information from Firebase
     */
    func getUserInfo() {
        currentUserReference.observeEventType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            
            for item in snapshot.children {
                let item = item as! FDataSnapshot
                switch(item.key) {
                case "username": UserInformation.sharedInstance.name = (item.value as? String) ?? ""
                case "sortingOrder": UserInformation.sharedInstance.sortingOrder = (item.value as? String) ?? ""
                case "email": UserInformation.sharedInstance.email = (item.value as? String) ?? ""
                default : continue
                }
            }
        }
    }

    func removeOldData(category:String) {
        
        MBTFirebaseDataService.dataService.expensesreference.childByAppendingPath(category).removeValue()
    }
    func getUserName(handler:((String)->Void)) {
        currentUserReference.childByAppendingPath("username").observeEventType(.Value) { (snapshot:FDataSnapshot!) -> Void in
            if let name = snapshot.value {
                handler((name as? String) ?? "")
            }
        }
    }
    /**
    *  <#Description#>
    */
    func changeEmail() {
    
        baseRef.changeEmailForUser("oldemail@example.com", password: "correcthorsebatterystaple",
            toNewEmail: "newemail@firebase.com", withCompletionBlock: { error in
                
                if error != nil {
                    // There was an error processing the request
                } else {
                    // Email changed successfully
                }
        })
    }
    
    func changePassword(oldPassword: String, newPassword: String, withError:((NSError?)->Void)) {
        let email = UserInformation.sharedInstance.email
        if let email = email {
            baseRef.changePasswordForUser(email, fromOld: oldPassword,
                toNew: newPassword, withCompletionBlock: { error in
                    withError(error)
            })
        }
    }
    
    func changeUserName(name: String) {
        currentUserReference.childByAppendingPath("username").setValue(name)
    }
    
    func reSetPassword() {
        let ref = Firebase(url: "https://<YOUR-FIREBASE-APP>.firebaseio.com")
        ref.resetPasswordForUser("bobtony@example.com", withCompletionBlock: { error in
            
            if error != nil {
                // There was an error processing the request
            } else {
                // Password reset sent successfully
            }
        })
    }
    
    func deleteAccount(email:String, password: String, handler:((NSError?)->Void)) {

        baseReference.removeUser(email, password: password,
            withCompletionBlock: { error in
                
                handler(error)
        })
    }
}
