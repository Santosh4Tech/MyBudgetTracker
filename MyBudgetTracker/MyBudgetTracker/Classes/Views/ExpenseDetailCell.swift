//
//  ExpenseDetailCell.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/25/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit


protocol MBTResizeCellDelegate: NSObjectProtocol {
    
    func reSizetheCell(cell: ExpenseDetailCell, cellSize: Float, toExpand: Bool)
    
}

/// Convenience Class to display the Expenses entries under a particular category
class ExpenseDetailCell: UITableViewCell {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    
    weak var delegate: MBTResizeCellDelegate?
    var expense: Expense?
    var cellHeight: Float?
    
    override func prepareForReuse() {
        headingLabel.text = ""
        amountLabel.text = ""
        dateLabel.text = ""
        descriptionLabel.text = ""
        moreButton.setTitle("More", forState: .Normal)
    }
    
    /**
     This method is going to set the different field of an expense
     
     - parameter expensesDetail: it contains the details of a expense
     */
    
    func configureCellWithData(expensesDetail: Expense) {
        expense = expensesDetail
        
        headingLabel.text = expensesDetail.title ?? ""
        
        if let amount = expensesDetail.amount {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            amountLabel.text = formatter.stringFromNumber(NSNumber(integer: Int(amount) ?? 0))
        }
        
        if let expenseDate = expensesDetail.expenseDate {
            dateLabel.text = "Date: \(expenseDate)"
        }
        
        descriptionLabel.text = expensesDetail.fullDescription ?? ""
        setDescriptionText(expensesDetail.fullDescription ?? "")
    }
    
    func setDescriptionText(text: String) {

        //set More button 
        
        cellHeight = Float(text.heightWithConstrainedWidth(holderView.frame.size.width-80, font: headingLabel.font))
        if (cellHeight ?? 1)/16 < 2.5 {
            moreButton.hidden = true
        } else {
            moreButton.hidden = false
        }
    }
    
    @IBAction func didTapEditButton(sender: UIButton) {
        
        
    }
    @IBAction func didTapMoreInfoButton(sender: UIButton) {
        if let delegate = delegate {
            if moreButton.titleLabel?.text == "Less" {
                moreButton.setTitle("More", forState: .Normal)
                delegate.reSizetheCell(self, cellSize: cellHeight ?? 0, toExpand: false)
            } else {
                moreButton.setTitle("Less", forState: .Normal)
                delegate.reSizetheCell(self, cellSize: cellHeight ?? 0, toExpand: true)
            }
        }
    }
    
}

extension String {
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(self)
    }
    func isNumeric() -> Bool
    {
        let scanner = NSScanner(string: self)
        
        // A newly-created scanner has no locale by default.
        // We'll set our scanner's locale to the user's locale
        // so that it recognizes the decimal separator that
        // the user expects (for example, in North America,
        // "." is the decimal separator, while in many parts
        // of Europe, "," is used).
        scanner.locale = NSLocale.currentLocale()
        
        return scanner.scanDecimal(nil) && scanner.atEnd
    }
}
