//
//  CategoryCell.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/25/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit



/// Convenience class for the handeling of expenses categories 
class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    override func awakeFromNib() {
        layer.cornerRadius = 20.0
        layer.masksToBounds = true
        layer.borderColor = UIColor.buttonColor().CGColor
        layer.borderWidth = 1.0
    }
    
    func configureCellWithDetails(title: String) {
        itemTitleLabel.text = title
    }
    
}
