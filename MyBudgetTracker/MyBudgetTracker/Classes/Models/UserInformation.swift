//
//  UserInformation.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 5/2/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class UserInformation: NSObject {

    static let sharedInstance = UserInformation()
    var name: String?
    var email: String?
    var sortingOrder:String?
    
    private override init() {
    
    }
}
