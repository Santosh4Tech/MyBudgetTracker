//
//  CustomAnimation.swift
//  MyBudgetTracker
//
//  Created by Santosh Kumar Sahoo on 5/9/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import UIKit

class CustomAnimation: NSObject , UIViewControllerAnimatedTransitioning{
    var duration    = 0.4
    var direction:ViewTranslationDirection?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
        let containerView = transitionContext.containerView()

        toViewController.view.frame = CGRectOffset(finalFrameForVC, (direction?.getComponent().0) ?? 0, (direction?.getComponent().1) ?? 0)
        containerView!.addSubview(toViewController.view)
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                toViewController.view.frame = finalFrameForVC
            },
            completion: { finished in
                transitionContext.completeTransition(true)
                fromViewController.view.alpha = 1.0
            }
        )
    }
    
}

/// Custom dismissal of viewController
class CustomDismissViewController: NSObject , UIViewControllerAnimatedTransitioning{
    let duration    = 0.4
    var presenting  = true
    var direction:ViewTranslationDirection?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
        return duration
    }
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
        let containerView = transitionContext.containerView()
        toViewController.view.frame = finalFrameForVC
        toViewController.view.alpha = 0.5
        containerView!.addSubview(toViewController.view)
        containerView!.sendSubviewToBack(toViewController.view)
        
        let snapshotView = fromViewController.view.snapshotViewAfterScreenUpdates(false)
        snapshotView.frame = fromViewController.view.frame
        containerView!.addSubview(snapshotView)
        
        let bounds = UIScreen.mainScreen().bounds
        
        fromViewController.view.removeFromSuperview()
        
        UIView.animateWithDuration(duration, animations: {
            snapshotView.frame = CGRectOffset(finalFrameForVC, 0, bounds.size.height)
            toViewController.view.alpha = 1.0
            }, completion: {
                finished in
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
    
}

extension UIColor {
    class func buttonColor() -> UIColor {
        
        return UIColor(red: 0/255.0, green: 186.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    }
}

extension UIView {
    
    class func getGradientViewWithFrame(frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0).CGColor, UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.7).CGColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = frame
        return gradient
    }
}