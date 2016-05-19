//
//  MBTExpenditureViewController.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 3/25/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit
import Firebase

enum ViewTranslationDirection {
    case Left,Right,Bottom,Top
    
    func getComponent()->(CGFloat,CGFloat){
        let bounds = UIScreen.mainScreen().bounds
        
        switch(self) {
        case .Left: return (-bounds.width, 0)
        case .Right: return (bounds.width, 0)
        case .Top: return (0, -bounds.height)
        case .Bottom: return (0,bounds.height)
        }
    }
}

/// Convenience Class for showing the expense of the user under different category

class MBTExpenditureViewController: UIViewController {
    
    
    @IBOutlet weak var menuItemCollectionView: UICollectionView!
    @IBOutlet weak var expenditureTableView: UITableView!
    @IBOutlet weak var noRecordImageView: UIImageView!
    @IBOutlet weak var holdOnView: UIView!
    @IBOutlet weak var holdOnActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    let longPressGesture = UILongPressGestureRecognizer()
    let transition = CustomAnimation()
    
    private var menuBarItems = [String]()
    private var expandedCellIndex: Int?
    private var expandedCellSize: Float?
    private var expensesList = [Expense]()
    private var selectedCellIndex: Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        holdOnActivityIndicator.startAnimating()        
        longPressGesture.addTarget(self, action: #selector(handleLongPressedGesture))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        menuItemCollectionView.addGestureRecognizer(longPressGesture)
        
        expenditureTableView.estimatedRowHeight = 80
        expenditureTableView.rowHeight = UITableViewAutomaticDimension
        
        getCategories()
        
    }
    
    /**
     Rename and Delete operation of Custom Category is going to be handled with LongPressGesture
     */
    func handleLongPressedGesture() {
        
        if longPressGesture.state != UIGestureRecognizerState.Ended {
            return
        }
        
        let p = longPressGesture.locationInView(menuItemCollectionView)
        let indexPath = menuItemCollectionView.indexPathForItemAtPoint(p)
        
        guard let index = indexPath else {
            return
        }
        guard index.row > 6 else {
            //is trying to rename or delete the System Category
            presentViewController(MBTAlertMessage().showAlert("Oops..!!", message: "Can't Rename Or Delete This Category"), animated: true, completion: nil)
            return
        }
        selectedCellIndex = index.row
        let alert = UIAlertController(title: menuBarItems[index.row], message: "", preferredStyle: .ActionSheet)
        let action1 = UIAlertAction(title: "Rename", style: .Default, handler: { (action) -> Void in
            let renameVC = UIStoryboard(name: "Update", bundle: nil).instantiateViewControllerWithIdentifier("rename") as! MBTRenameViewController
            renameVC.selectedCategoryName = self.menuBarItems[index.row]
            renameVC.categoryList = self.menuBarItems
            self.presentViewController(renameVC, animated: true, completion: nil)
        })
        
        let action2 = UIAlertAction(title: "Delete", style: .Default, handler: { (action) -> Void in
            
            if self.selectedCellIndex >= self.menuBarItems.count - 1 {
                self.selectedCellIndex -= 1
            }
            MBTFirebaseDataService.dataService.expensesreference.childByAppendingPath(self.menuBarItems[index.row]).removeValue()
            MBTFirebaseDataService.dataService.customCategoryreference.childByAppendingPath(self.menuBarItems[index.row]).removeValue()
        })
        
        
        let action3 = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapAddButton(sender: UIButton) {
        expandedCellIndex = nil
        expandedCellSize = nil
        let vc = getVCToPresent()
        vc.expensesCategoryTitle = menuBarItems[selectedCellIndex]
        presentViewController(vc, animated: true, completion: nil)
    }
}

private extension MBTExpenditureViewController {
    
    /**
     Expenses categories from Firebase is going to be fetched
     */
    func getCategories() {
        
        MBTFirebaseDataService.dataService.getCategoryList() { (menuBarItems) -> Void in
            self.menuBarItems.removeAll()
            self.menuBarItems = menuBarItems
            self.expensesUnderCategory(self.selectedCellIndex)
            self.menuItemCollectionView.reloadData()
        }
        
    }
    /**
     The expenses entries under a Category is going to be fetched
     
     - parameter index: index of menuBarItems Array which specify the particular Category.
     */
    func expensesUnderCategory(index: Int) {
        if menuBarItems.isEmpty == false {
            let category = menuBarItems[index]
            MBTFirebaseDataService.dataService.getExpense(category, completionHandler: { (expenseList) -> Void in
                self.expensesList.removeAll()
                self.sort(expenseList)
            })
        }
    }
    
    func sort(expenseList: Array<Expense>) {
        MBTFirebaseDataService.dataService.currentUserReference.childByAppendingPath("sortingOrder").observeEventType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            let temp1 = snapshot.value
            let sortBy = temp1 as? String
            if let temp = SortBy(rawValue: sortBy ?? "") {
                switch(temp){
                    
                case .Amount:   self.expensesList = expenseList.sort { Int($0.amount ?? "") ?? 0 > Int($1.amount ?? "") ?? 0 }
                    
                case .Date: let dateFormatter = NSDateFormatter()
                
                self.expensesList = expenseList.sort{(dateFormatter.dateFromString($0.expenseDate ?? "") ?? NSDate()).compare(dateFormatter.dateFromString($1.expenseDate ?? "") ?? NSDate()) == NSComparisonResult.OrderedAscending }
                    
                case .Title:    self.expensesList = expenseList.sort { $0.title?.uppercaseString ?? "" < $1.title?.uppercaseString ?? "" }
                    
                case .None: self.expensesList = expenseList
                }
                //self.holdOnView.hidden = true
                self.expandedCellIndex = nil
                self.expandedCellSize = nil
                self.expenditureTableView.reloadData()
            }
        }
    }
    
}

extension MBTExpenditureViewController: UITableViewDataSource,UITableViewDelegate {
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expensesList.count == 0 {
            self.noRecordImageView.hidden = false
        } else {
            self.noRecordImageView.hidden = true
        }
        return expensesList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("expenditureCell", forIndexPath: indexPath) as! ExpenseDetailCell
        cell.delegate = self
        cell.configureCellWithData(self.expensesList[indexPath.row])
        return cell
    }
    //MARK: - UITableViewDelegate methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let expandedCellIndex = expandedCellIndex where expandedCellIndex == indexPath.row {
            return CGFloat(expandedCellSize ?? 0) + 65
        }
        return 100
        
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let Edit = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) -> Void in
            self.doPresentEditViewController(self.expensesList[indexPath.row])
        }
        Edit.backgroundColor = UIColor.buttonColor()
        let Delete = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            let alert = UIAlertController(title: "Delete", message: "Are you sure to delete ?", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (deleteAction) -> Void in
                MBTFirebaseDataService.dataService.expensesreference.childByAppendingPath(self.menuBarItems[self.selectedCellIndex]).childByAppendingPath(self.expensesList[indexPath.row].reference).removeValue()
            })
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        Delete.backgroundColor = UIColor.redColor()
        
        return [Delete,Edit]
    }
    
}

extension MBTExpenditureViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
    //MARK: - UICollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuBarItems.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("expenditureItem", forIndexPath: indexPath) as! CategoryCell
        cell.configureCellWithDetails(self.menuBarItems[indexPath.row])
        
        if indexPath.row == selectedCellIndex {
            cell.backgroundColor = UIColor.buttonColor()
            cell.itemTitleLabel.textColor = UIColor.whiteColor()
        } else {
            
            cell.backgroundColor = UIColor.whiteColor()
            cell.itemTitleLabel.textColor = UIColor.buttonColor()
        }
        return cell
        
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        guard selectedCellIndex != indexPath.row else {
            return
        }
        if selectedCellIndex == 0 && indexPath.row != 0 {
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? CategoryCell
            selectedCell?.backgroundColor = UIColor.whiteColor()
            selectedCell?.itemTitleLabel.textColor = UIColor.buttonColor()
            
        }
        
        if selectedCellIndex != indexPath.row {
            let index = NSIndexPath(forRow: selectedCellIndex, inSection: 0)
            var cell = collectionView.cellForItemAtIndexPath(index) as? CategoryCell
            cell?.backgroundColor = UIColor.whiteColor()
            cell?.itemTitleLabel.textColor  = UIColor.buttonColor()
            cell = collectionView.cellForItemAtIndexPath(indexPath) as? CategoryCell
            cell?.backgroundColor = UIColor.buttonColor()
            cell?.itemTitleLabel.textColor  = UIColor.whiteColor()
        }
        selectedCellIndex = indexPath.row
        self.expensesUnderCategory(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(getWidthForCell(menuBarItems[indexPath.row]), self.menuItemCollectionView.frame.height-20)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 10, 0, 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    func getWidthForCell(title: String)-> CGFloat {
        let width = title.sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(20)]).width+20
        return width
    }
}

extension MBTExpenditureViewController: MBTResizeCellDelegate {
    
    
    @IBAction func didTapMoreButton(sender: UIBarButtonItem) {
        
        let mainMenuVC = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewControllerWithIdentifier("mainMenu")
        mainMenuVC.transitioningDelegate = self

        performAnimatedViewTranslation(mainMenuVC.view, direction: .Left, duration: 0.4)
        self.addChildViewController(mainMenuVC)
        mainMenuVC.didMoveToParentViewController(self)
        
    }
    
    func doPresentEditViewController(expense: Expense) {
        let vc = getVCToPresent()
        vc.expense = expense
        vc.expensesCategoryTitle = menuBarItems[selectedCellIndex]
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func doPresentViewController(expensesCategoryTitle: String) {
        expandedCellIndex = nil
        expandedCellSize = nil
        let vc = getVCToPresent()
        vc.expensesCategoryTitle = expensesCategoryTitle
        presentViewController(vc, animated: true, completion: nil)
    }
    
    private func getVCToPresent() -> MBTExpenseEntryViewController{
        
        transition.direction = .Bottom
        transition.duration = 0.4
        let vc = UIStoryboard(name: "Expenses", bundle: nil).instantiateViewControllerWithIdentifier("expensesEntery1") as? MBTExpenseEntryViewController
        vc?.transitioningDelegate = self
        return vc ?? MBTExpenseEntryViewController()
    }
    
    func reSizetheCell(cell: ExpenseDetailCell, cellSize: Float, toExpand: Bool) {
        
        expenditureTableView.beginUpdates()

        if toExpand {
            if let expandedCellIndex = expandedCellIndex {
                //if a cell is already expanded, Handle the Title
                let indexPath = NSIndexPath(forRow: expandedCellIndex, inSection: 0)
                let cell = expenditureTableView.cellForRowAtIndexPath(indexPath) as? ExpenseDetailCell
                cell?.moreButton.setTitle("More", forState: .Normal)
            }
            let index = expenditureTableView.indexPathForCell(cell)
            cell.descriptionLabel.numberOfLines = 0
            expandedCellIndex = index?.row
            expandedCellSize = cellSize
        } else {
            expandedCellIndex = nil
            expandedCellSize = nil
        }
        expenditureTableView.endUpdates()
    }
}

extension MBTExpenditureViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
}

extension UIViewController {
    
    /**
     Add View as sub-view  to Parent View with Animation
     
     - parameter subView:   is going to be a subView
     - parameter direction: direction of animation
     - parameter duration:  animation duration
     */
    func performAnimatedViewTranslation(subView: UIView, direction: ViewTranslationDirection, duration: NSTimeInterval ) {
        let component = direction.getComponent()
        subView.transform = CGAffineTransformMakeTranslation(component.0, component.1)
        
        view.addSubview(subView)
        view.bringSubviewToFront(subView)
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                subView.transform = CGAffineTransformMakeTranslation(0, 0)
            },
            completion: { finished in
                
            }
        )
    }
    /**
     Remove sub-View from Parent View with Animation
     
     - parameter view:      Current View
     - parameter direction: direction of animation
     */
    
    func removeViewWithAnimation(view: UIView, direction:ViewTranslationDirection) {
        
        let component = direction.getComponent()

        switch direction {
    
        case .Left:
            view.frame = CGRectMake(view.frame.origin.x + view.frame.width , view.frame.origin.y, view.frame.width, view.frame.height)
            
        case .Right:
            view.frame = CGRectMake(view.frame.origin.x - view.frame.width , view.frame.origin.y, view.frame.width, view.frame.height)
            
        case .Bottom:
            view.frame = CGRectMake(view.frame.origin.x , view.frame.origin.y - view.frame.height, view.frame.width, view.frame.height)
            
        case .Top:
            view.frame = CGRectMake(view.frame.origin.x , view.frame.origin.y + view.frame.height, view.frame.width, view.frame.height)
        }
        self.view.transform = CGAffineTransformMakeTranslation(component.0, component.1)
        
        UIView.animateWithDuration(0.4, animations: {self.view.transform = CGAffineTransformMakeTranslation(0, 0)},
                                   completion: {(value: Bool) in
                                    self.view.removeFromSuperview()
                                    self.removeFromParentViewController()
        })
        
    }
    
}



