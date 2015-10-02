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
        case Unzoomed
        case Zoomed
    }
    
    typealias ZoomingViews = (backgroundColourView: UIView, imageView: UIView)
    
    private let kZoomingIconTransitionDuration: NSTimeInterval = 1.0
    private let kZoomingIconTransitionZoomedScale: CGFloat = 15
    private let kZoomingIconTransitionBackgroundScale: CGFloat = 0.80
    
    var operation: UINavigationControllerOperation = .None
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval{
        
        return kZoomingIconTransitionDuration
        
    }
    
    func configureViewsForState(state: TransitionState, containerView: UIView, backgroundViewController: UIViewController,
        viewsInBackground: ZoomingViews, viewsInForeground: ZoomingViews, snapshotViews: ZoomingViews) {
            
            switch state {
            case .Unzoomed:
                backgroundViewController.view.transform = CGAffineTransformIdentity
                backgroundViewController.view.alpha = 1
                
                snapshotViews.backgroundColourView.transform = CGAffineTransformIdentity
                snapshotViews.backgroundColourView.frame = containerView.convertRect(viewsInBackground.backgroundColourView.frame, fromView: viewsInBackground.backgroundColourView.superview)
                snapshotViews.imageView.frame = containerView.convertRect(viewsInBackground.imageView.frame, fromView: viewsInBackground.imageView.superview)
                
            case .Zoomed:
                backgroundViewController.view.transform = CGAffineTransformMakeScale(kZoomingIconTransitionBackgroundScale, kZoomingIconTransitionBackgroundScale)
                backgroundViewController.view.alpha = 0
                
                snapshotViews.backgroundColourView.transform = CGAffineTransformMakeScale(kZoomingIconTransitionZoomedScale, kZoomingIconTransitionZoomedScale)
                snapshotViews.backgroundColourView.center = containerView.convertPoint(viewsInForeground.imageView.center, fromView: viewsInForeground.imageView.superview)
                snapshotViews.imageView.frame = containerView.convertRect(viewsInForeground.imageView.frame, fromView: viewsInForeground.imageView.superview)
                
            }
    }
    
    
    // This method can only  be a nop if the transition is interactive and not a
    // percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning){
        
        if operation == .Push {
            
            executeZoomTransition(transitionContext)
            
        } else if operation == .Pop {
            
            executeUnzoomTransition(transitionContext)
            
        }
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
    
    
    
    // MARK: private
    
    private func executeZoomTransition(transitionContext: UIViewControllerContextTransitioning){
        
        let duration = transitionDuration(transitionContext)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        
        let fromIconImageView = (fromViewController as! ZoomingIconViewController).zoomingIconImageViewForTransition(self)!
        let toIconImageView = (toViewController as! ZoomingIconViewController).zoomingIconImageViewForTransition(self)!
        
        let fromBackgroundColourView = (fromViewController as! ZoomingIconViewController).zoomingIconBackgroundColourViewForTransition(self)!
        let toBackgroundColourView = (toViewController as! ZoomingIconViewController).zoomingIconBackgroundColourViewForTransition(self)!
        
        // create view snapshots
        // view controller need to be in view hierarchy for snapshotting
        containerView.addSubview(fromViewController.view)
        let snapshot_fromBackgroundColourView = fromBackgroundColourView.snapshotViewAfterScreenUpdates(false)
        
        let snapshot_fromIconImageView = UIImageView(image: fromIconImageView.image)
        snapshot_fromIconImageView.contentMode = .ScaleAspectFit
        
        
        // Pre-Animation states
        fromViewController.view.transform = CGAffineTransformIdentity
        fromViewController.view.alpha = 1
        
        snapshot_fromBackgroundColourView.transform = CGAffineTransformIdentity
        snapshot_fromBackgroundColourView.frame = containerView.convertRect(fromBackgroundColourView.frame, fromView: fromBackgroundColourView.superview)
        snapshot_fromIconImageView.frame = containerView.convertRect(fromIconImageView.frame, fromView: fromIconImageView.superview)
        
        // setup animation
        fromBackgroundColourView.hidden = true
        toBackgroundColourView.hidden = true
        
        fromIconImageView.hidden = true
        toIconImageView.hidden = true
        
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(snapshot_fromBackgroundColourView)
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshot_fromIconImageView)
        
        let toViewBackgroundColor = toViewController.view.backgroundColor
        toViewController.view.backgroundColor = UIColor.clearColor()
        
        // Need to layout now if we want the correct parameters for frame
        toViewController.view.layoutIfNeeded()
        
        // perform animation
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1,
            initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                
                // Post-Animation states
                fromViewController.view.transform =
                    CGAffineTransformMakeScale(self.kZoomingIconTransitionBackgroundScale, self.kZoomingIconTransitionBackgroundScale)
                fromViewController.view.alpha = 0
                
                snapshot_fromBackgroundColourView.transform =
                    CGAffineTransformMakeScale(self.kZoomingIconTransitionZoomedScale, self.kZoomingIconTransitionZoomedScale)
                snapshot_fromBackgroundColourView.center = containerView.convertPoint(toIconImageView.center, fromView: toIconImageView.superview)
                
                let convertedFrame = containerView.convertRect(toIconImageView.frame, fromView: toIconImageView.superview!)
                snapshot_fromIconImageView.frame = convertedFrame
                
            },
            completion: { (finished) in
                
                fromViewController.view.transform = CGAffineTransformIdentity
                
                snapshot_fromBackgroundColourView.removeFromSuperview()
                snapshot_fromIconImageView.removeFromSuperview()
                
                fromBackgroundColourView.hidden = false
                toBackgroundColourView.hidden = false
                
                fromIconImageView.hidden = false
                toIconImageView.hidden = false
                
                toViewController.view.backgroundColor = toViewBackgroundColor
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                
        })
        
        
    }
    
    private func executeUnzoomTransition(transitionContext: UIViewControllerContextTransitioning){
        
        
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
    
}
