//
//  ZoomingIconTransition.swift
//  ZoomingIconsMenu
//
//  Created by asu on 2015-10-01.
//  Copyright © 2015 asu. All rights reserved.
//

import UIKit


protocol ZoomingIconViewController {
    func zoomingIconBackgroundColourViewForTransition(transition: ZoomingIconTransition) -> UIView?
    func zoomingIconImageViewForTransition(transition: ZoomingIconTransition) -> UIImageView?
}

class ZoomingIconTransition: NSObject, UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate{

    enum TransitionState {
        case Initial
        case Final
    }
    
    typealias ZoomingViews = (coloredView: UIView, imageView: UIView)
    
    private let kZoomingIconTransitionDuration: NSTimeInterval = 0.6
    private let kZoomingIconTransitionZoomedScale: CGFloat = 15
    private let kZoomingIconTransitionBackgroundScale: CGFloat = 0.80
    
    var operation: UINavigationControllerOperation = .None
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval{
        
        return kZoomingIconTransitionDuration
        
    }
    
    func configureViewsForState(state: TransitionState, containerView: UIView, backgroundViewController: UIViewController, viewsInBackground: ZoomingViews, viewsInForeground: ZoomingViews, snapshotViews: ZoomingViews) {
        switch state {
        case .Initial:
            backgroundViewController.view.transform = CGAffineTransformIdentity
            backgroundViewController.view.alpha = 1
            
            snapshotViews.coloredView.transform = CGAffineTransformIdentity
            snapshotViews.coloredView.frame = containerView.convertRect(viewsInBackground.coloredView.frame, fromView: viewsInBackground.coloredView.superview)
            snapshotViews.imageView.frame = containerView.convertRect(viewsInBackground.imageView.frame, fromView: viewsInBackground.imageView.superview)
            
        case .Final:
            backgroundViewController.view.transform = CGAffineTransformMakeScale(kZoomingIconTransitionBackgroundScale, kZoomingIconTransitionBackgroundScale)
            backgroundViewController.view.alpha = 0
            
            snapshotViews.coloredView.transform = CGAffineTransformMakeScale(kZoomingIconTransitionZoomedScale, kZoomingIconTransitionZoomedScale)
            snapshotViews.coloredView.center = containerView.convertPoint(viewsInForeground.imageView.center, fromView: viewsInForeground.imageView.superview)
            snapshotViews.imageView.frame = containerView.convertRect(viewsInForeground.imageView.frame, fromView: viewsInForeground.imageView.superview)
      
        }
    }
    
    
    // This method can only  be a nop if the transition is interactive and not a 
    // percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning){
        let duration = transitionDuration(transitionContext)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!

        
        var backgroundViewController = fromViewController
        var foregroundViewController = toViewController
        
        if operation == .Pop {
            backgroundViewController = toViewController
            foregroundViewController = fromViewController
        }

        let backgroundImageView = (backgroundViewController as! ZoomingIconViewController).zoomingIconImageViewForTransition(self)!
        let foregroundImageView = (foregroundViewController as! ZoomingIconViewController).zoomingIconImageViewForTransition(self)!
        
        let backgroundColourView = (backgroundViewController as! ZoomingIconViewController).zoomingIconBackgroundColourViewForTransition(self)!
        let foregroundColourView = (foregroundViewController as! ZoomingIconViewController).zoomingIconBackgroundColourViewForTransition(self)!

        
        // create view snapshots
        // view controller needs to be in view hierarchy for snapshotting
        containerView.addSubview(backgroundViewController.view)
        let snapshotOfColoredView = backgroundColourView.snapshotViewAfterScreenUpdates(false)
        
        let snapshotOfImageView = UIImageView(image: backgroundImageView.image)
        snapshotOfImageView.contentMode = .ScaleAspectFit
        
        // setup states for animation
        backgroundColourView.hidden = true
        foregroundColourView.hidden = true
        
        backgroundImageView.hidden = true
        foregroundImageView.hidden = true
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.addSubview(backgroundViewController.view)
        containerView.addSubview(snapshotOfColoredView)
        containerView.addSubview(foregroundViewController.view)
        containerView.addSubview(snapshotOfImageView)
        
        let foregroundViewBackgroundColor = foregroundViewController.view.backgroundColor
        foregroundViewController.view.backgroundColor = UIColor.clearColor()
        
        var preTransitionState = TransitionState.Initial
        var postTransitionState = TransitionState.Final
        
        if operation == .Pop {
            preTransitionState = TransitionState.Final
            postTransitionState = TransitionState.Initial
        }
        
        configureViewsForState(preTransitionState, containerView: containerView,
            backgroundViewController: backgroundViewController,
            viewsInBackground: (backgroundColourView, backgroundImageView),
            viewsInForeground: (foregroundColourView, foregroundImageView),
            snapshotViews: (snapshotOfColoredView, snapshotOfImageView))
        
        // setup animation
        containerView.addSubview(fromViewController.view!)
        containerView.addSubview(toViewController.view!)
    
        
        // perform animation
        
        // need to layout now if we want the correct parameters for frame
        foregroundViewController.view.layoutIfNeeded()
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1,
            initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
                
                //toViewController.view.alpha = 1
                self.configureViewsForState(postTransitionState, containerView: containerView,
                    backgroundViewController: backgroundViewController,
                    viewsInBackground: (backgroundColourView, backgroundImageView),
                    viewsInForeground: (foregroundColourView, foregroundImageView),
                    snapshotViews: (snapshotOfColoredView, snapshotOfImageView))
                
            },
            completion: { (finished) in
                
                backgroundViewController.view.transform = CGAffineTransformIdentity
                
                snapshotOfColoredView.removeFromSuperview()
                snapshotOfImageView.removeFromSuperview()
                
                backgroundColourView.hidden = false
                foregroundColourView.hidden = false
                
                backgroundImageView.hidden = false
                foregroundImageView.hidden = false
                
                foregroundViewController.view.backgroundColor = foregroundViewBackgroundColor
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())

        })
        
    }
    
    // MARK: UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

            if fromVC is ZoomingIconViewController &&
                toVC is ZoomingIconViewController {
                    self.operation = operation
                    
                    return self
            }
            return nil
    }

}
