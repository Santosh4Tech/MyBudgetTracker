//
//  UserInformationCell.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 4/29/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit
import Firebase

class UserInformationCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        doSetInfo()
    }
    func doSetInfo() {
        userNameLabel.text = UserInformation.sharedInstance.name ?? ""
        emailLabel.text = UserInformation.sharedInstance.email ?? ""
    }
}
