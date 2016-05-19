//
//  NavigationDrawerCell.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 4/16/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class NavigationDrawerCell: UITableViewCell {

    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuItemTitleLabel: UILabel!
    
    func configureCell(title: String, icon:String) {
        menuIcon.image = UIImage(named: icon)
        menuItemTitleLabel.text = title
    }
}
