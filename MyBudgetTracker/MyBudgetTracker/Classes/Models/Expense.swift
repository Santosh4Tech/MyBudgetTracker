//
//  Expense.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/31/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class Expense: NSObject {

    
    var title: String?
    var amount: String?
    var expenseDate:String?
    var fullDescription: String?
    var reference: String?
    
    convenience init(briefHeader: String?, amount: String?, expenseDate:String?, fullDescription: String?, reference: String?) {
        self.init()
        self.title = briefHeader
        self.amount = amount
        self.expenseDate = expenseDate
        self.fullDescription = fullDescription
        self.reference = reference
    }
}
