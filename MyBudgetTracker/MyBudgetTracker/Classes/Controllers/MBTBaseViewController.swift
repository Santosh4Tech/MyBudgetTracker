//
//  MBTBaseViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/25/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit
import Firebase


/// Convenience Class for the Home Page Of the App
class MBTBaseViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var welComeLabel: UILabel!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var homePageActivityIndicator: UIActivityIndicatorView!

    //MARK: - Properties
    var clockLabelFontSize: CGFloat?
    var dateLabelFontSize: CGFloat?
    var welComeLabelFontSize: CGFloat?
    
    //MARK: - ViewController LifeCycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        homePageActivityIndicator.startAnimating()
        clockLabelFontSize = clockLabel.font.pointSize
        dateLabelFontSize = dateLabel.font.pointSize
        welComeLabelFontSize = welComeLabel.font.pointSize
        
        clockLabel.hidden = true
        dateLabel.hidden = true
        welComeLabel.hidden = true
        setDateAndTime()
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(setDateAndTime), userInfo: nil, repeats: true)
        panGesture.addTarget(self, action: #selector(panGestureHandler))
        if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil {
            MBTFirebaseDataService.dataService.getUserName { (name) -> Void in
                
                self.welComeLabel.text = "WelCome \(name ?? "Guest!")"
                
            }
        }
    }
    
    //MARK: - Utility methods
    /**
     Convenience method for setting of Date and Time
     */
    func setDateAndTime() {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year, .Minute, .Hour], fromDate: date)
        
        
        homePageActivityIndicator.stopAnimating()
        clockLabel.hidden = false
        dateLabel.hidden = false
        welComeLabel.hidden = false
        
        dateLabel.text = String(components.day) + " \(components.month.month()) " + String(components.year)
        let minute = components.minute < 10 ? "0\(components.minute)":"\(components.minute)"
        clockLabel.text = String(components.hour) + " : " + minute + (components.hour < 12 ? " AM" : " PM")
    }
    
    /**
     Convenience method to handel PanGesture sender: UIPanGestureRecognizer
     */
    
    func panGestureHandler(sender: UIPanGestureRecognizer) {
        let velocity = panGesture.velocityInView(self.view)
        
        if -80...80 ~= velocity.x && 0 > velocity.y{
            view.alpha = view.alpha * 0.98
            handleFontScaling()
            if view.alpha < 0.4 && clockLabel.font.pointSize < 10 {
                if NSUserDefaults.standardUserDefaults().valueForKey("uid") != nil && MBTFirebaseDataService.dataService.currentUserReference.authData != nil {
                    MBTFirebaseDataService.dataService.getUserInfo()
                    let viewController = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewControllerWithIdentifier("expenditureDetail")
                    presentViewController(viewController, animated: true, completion: nil)
                } else {
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loginPage")
                    presentViewController(viewController, animated: true, completion: nil)
                }
                view.alpha = 1.0
            }
        }
        if sender.state == .Ended {
            view.alpha = 1.0
            reSetFontScaling()
        }
    }
    
    func handleFontScaling() {
        clockLabel.font = UIFont(name: (clockLabel.font?.fontName) ?? "", size: (clockLabel.font?.pointSize)! - 0.8)
        dateLabel.font = UIFont(name: (clockLabel.font?.fontName) ?? "", size: (dateLabel.font?.pointSize)! - 0.5)
        welComeLabel.font = UIFont(name: (clockLabel.font?.fontName) ?? "", size: (welComeLabel.font?.pointSize)! - 0.5)
    }
    
    func reSetFontScaling() {
        clockLabel.font = UIFont(name: (clockLabel.font?.fontName) ?? "", size: clockLabelFontSize ?? 20)
        dateLabel.font = UIFont(name: (clockLabel.font?.fontName) ?? "", size: dateLabelFontSize ?? 20)
        welComeLabel.font = UIFont(name: (clockLabel.font?.fontName) ?? "", size: welComeLabelFontSize ?? 20)
    }
}

extension Int {
    
    func month()-> String {
        switch self {
        case 1:
            return "JAN"
        case 2:
            return "FEB"
        case 3:
            return "MAR"
        case 4:
            return "APR"
        case 5:
            return "MAY"
        case 6:
            return "JUN"
        case 7:
            return "JUL"
        case 8:
            return "AUG"
        case 9:
            return "SEP"
        case 10:
            return "OCT"
        case 11:
            return "NOV"
        case 12:
            return "DEC"
        default:
            return ""
        }
    }
}