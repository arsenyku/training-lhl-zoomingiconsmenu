//
//  ZoomingIconTransition.swift
//  ZoomingIconsMenu
//
//  Created by asu on 2015-10-01.
//  Copyright © 2015 asu. All rights reserved.
//

import UIKit

class ZoomingIconTransition: NSObject, UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate{

    private let kZoomingIconTransitionDuration: NSTimeInterval = 0.6
    
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval{
        
        return kZoomingIconTransitionDuration
        
    }
    
    // This method can only  be a nop if the transition is interactive and not a 
    // percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning){
        let duration = transitionDuration(transitionContext)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!

        // setup animation
        containerView.addSubview(fromViewController.view!)
        containerView.addSubview(toViewController.view!)
        toViewController.view.alpha = 0
    
        
        // perform animation
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1,
            initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
                toViewController.view.alpha = 1
            },
            completion: { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
        
    }
    
    // MARK: UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

            return self
    }

}
