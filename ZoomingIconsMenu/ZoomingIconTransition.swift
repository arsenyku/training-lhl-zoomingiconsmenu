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
    
    private let kZoomingIconTransitionDuration: NSTimeInterval = 2.0
    private let kZoomingIconTransitionZoomedScale: CGFloat = 15
    private let kZoomingIconTransitionBackgroundScale: CGFloat = 0.80
    
    var operation: UINavigationControllerOperation = .None
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval{
        
        return kZoomingIconTransitionDuration
        
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
        let startViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let endViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        
        let startBackgroundView = (startViewController as! ZoomingIconViewController).zoomingIconBackgroundColourViewForTransition(self)!
        let startIconView = (startViewController as! ZoomingIconViewController).zoomingIconImageViewForTransition(self)!

        let endBackgroundView = (endViewController as! ZoomingIconViewController).zoomingIconBackgroundColourViewForTransition(self)!
        let endIconView = (endViewController as! ZoomingIconViewController).zoomingIconImageViewForTransition(self)!
        
        // create view snapshots
        // view controller need to be in view hierarchy for snapshotting
        containerView.addSubview(startViewController.view)
        let snapshotOfStartBackgroundView = startBackgroundView.snapshotViewAfterScreenUpdates(false)
        let snapshotOfStartIconView = UIImageView(image: startIconView.image)
        snapshotOfStartIconView.contentMode = .ScaleAspectFit
        
        let endViewBackgroundColour = endViewController.view.backgroundColor!
        
        // setup animation
        prepareForAnimation(containerView,
            startViewController: startViewController, endViewController: endViewController,
            snapshotOfStartBackgroundView: snapshotOfStartBackgroundView, snapshotOfStartIconView: snapshotOfStartIconView,
            startBackgroundView: startBackgroundView, startIconView: startIconView,
            endBackgroundView: endBackgroundView, endIconView: endIconView)

        // Pre-Animation states
        startViewController.view.transform = CGAffineTransformIdentity
        startViewController.view.alpha = 1
        snapshotOfStartBackgroundView.transform = CGAffineTransformIdentity
        snapshotOfStartBackgroundView.frame = containerView.convertRect(startBackgroundView.frame, fromView: startBackgroundView.superview)
        snapshotOfStartIconView.frame = containerView.convertRect(startIconView.frame, fromView: startIconView.superview)
        
        // Need to layout now if we want the correct parameters for frame
        endViewController.view.layoutIfNeeded()
        
        // perform animation
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1,
            initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                
                // Post-Animation states
                startViewController.view.transform =
                    CGAffineTransformMakeScale(self.kZoomingIconTransitionBackgroundScale, self.kZoomingIconTransitionBackgroundScale)
                startViewController.view.alpha = 0
                
                snapshotOfStartBackgroundView.transform =
                    CGAffineTransformMakeScale(self.kZoomingIconTransitionZoomedScale, self.kZoomingIconTransitionZoomedScale)
                snapshotOfStartBackgroundView.center = containerView.convertPoint(endIconView.center, fromView: endIconView.superview)
                
                let convertedFrame = containerView.convertRect(endIconView.frame, fromView: endIconView.superview!)
                snapshotOfStartIconView.frame = convertedFrame
                
            },
            completion: { (finished) in
                
                self.cleanupAfterAnimation(startViewController, endViewController: endViewController,
                    endViewBackgroundColour: endViewBackgroundColour,
                    snapshotOfStartBackgroundView: snapshotOfStartBackgroundView, snapshotOfStartIconView: snapshotOfStartIconView,
                    startBackgroundView: startBackgroundView, startIconView: startIconView,
                    endBackgroundView: endBackgroundView, endIconView: endIconView)
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                
        })
        
        
    }
    
    private func executeUnzoomTransition(transitionContext: UIViewControllerContextTransitioning){
        
        let duration = transitionDuration(transitionContext)
        let startViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let endViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        
        let startBackgroundView = (startViewController as! ZoomingIconViewController).zoomingIconBackgroundColourViewForTransition(self)!
        let startIconView = (startViewController as! ZoomingIconViewController).zoomingIconImageViewForTransition(self)!
        
        let endBackgroundView = (endViewController as! ZoomingIconViewController).zoomingIconBackgroundColourViewForTransition(self)!
        let endIconView = (endViewController as! ZoomingIconViewController).zoomingIconImageViewForTransition(self)!
        
        // create view snapshots
        // view controller need to be in view hierarchy for snapshotting
        containerView.addSubview(endViewController.view)
        let snapshotOfEndBackgroundView = endBackgroundView.snapshotViewAfterScreenUpdates(false)
        let snapshotOfEndIconView = UIImageView(image: endIconView.image)
        snapshotOfEndIconView.contentMode = .ScaleAspectFit
        
        let startViewBackgroundColour = startViewController.view.backgroundColor!
        
        // setup animation
        prepareForAnimationUnzoom(containerView,
            startViewController: startViewController, endViewController: endViewController,
            snapshotOfEndBackgroundView: snapshotOfEndBackgroundView, snapshotOfEndIconView: snapshotOfEndIconView,
            startBackgroundView: startBackgroundView, startIconView: startIconView,
            endBackgroundView: endBackgroundView, endIconView: endIconView)
        
        
        // Pre-Animation states
        endViewController.view.transform =
            CGAffineTransformMakeScale(self.kZoomingIconTransitionBackgroundScale, self.kZoomingIconTransitionBackgroundScale)
        endViewController.view.alpha = 0
        
        snapshotOfEndBackgroundView.transform =
            CGAffineTransformMakeScale(self.kZoomingIconTransitionZoomedScale, self.kZoomingIconTransitionZoomedScale)
        snapshotOfEndBackgroundView.center = containerView.convertPoint(startIconView.center, fromView: startIconView.superview)
        
        let convertedFrame = containerView.convertRect(startIconView.frame, fromView: startIconView.superview!)
        snapshotOfEndIconView.frame = convertedFrame
        
        // Need to layout now if we want the correct parameters for frame
        startViewController.view.layoutIfNeeded()
        
        // perform animation
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1,
            initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                
                // Post-Animation states
                endViewController.view.transform = CGAffineTransformIdentity
                endViewController.view.alpha = 1
                
                snapshotOfEndBackgroundView.transform = CGAffineTransformIdentity
                snapshotOfEndBackgroundView.center = containerView.convertPoint(endIconView.center, fromView: endIconView.superview)
                
                let convertedFrame = containerView.convertRect(endIconView.frame, fromView: endIconView.superview!)
                snapshotOfEndIconView.frame = convertedFrame

                
            },
            completion: { (finished) in
                
                self.cleanupAfterAnimationUnzoom(startViewController, endViewController: endViewController,
                    endViewBackgroundColour: startViewBackgroundColour,
                    snapshotOfEndBackgroundView: snapshotOfEndBackgroundView, snapshotOfEndIconView: snapshotOfEndIconView,
                    startBackgroundView: startBackgroundView, startIconView: startIconView,
                    endBackgroundView: endBackgroundView, endIconView: endIconView)
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                
        })
    }
    
    private func prepareForAnimation(animationContainerView:UIView,
        startViewController: UIViewController, endViewController: UIViewController,
        snapshotOfStartBackgroundView:UIView, snapshotOfStartIconView:UIView,
        startBackgroundView:UIView, startIconView:UIView,
        endBackgroundView:UIView, endIconView:UIView){
        
            startBackgroundView.hidden = true
            endBackgroundView.hidden = true
            
            startIconView.hidden = true
            endIconView.hidden = true
            
            endViewController.view.backgroundColor = UIColor.clearColor()
            
            animationContainerView.backgroundColor = UIColor.whiteColor()
            animationContainerView.addSubview(startViewController.view)
            animationContainerView.addSubview(snapshotOfStartBackgroundView)
            animationContainerView.addSubview(endViewController.view)
            animationContainerView.addSubview(snapshotOfStartIconView)

    }
    
    private func cleanupAfterAnimation(
        startViewController: UIViewController, endViewController: UIViewController,
        endViewBackgroundColour:UIColor,
        snapshotOfStartBackgroundView:UIView, snapshotOfStartIconView:UIView,
        startBackgroundView:UIView, startIconView:UIView,
        endBackgroundView:UIView, endIconView:UIView){
            
            startViewController.view.transform = CGAffineTransformIdentity
            
            snapshotOfStartBackgroundView.removeFromSuperview()
            snapshotOfStartIconView.removeFromSuperview()
            
            startBackgroundView.hidden = false
            endBackgroundView.hidden = false
            
            startIconView.hidden = false
            endIconView.hidden = false
            
            endViewController.view.backgroundColor = endViewBackgroundColour
   
    }
    
    
    private func prepareForAnimationUnzoom(animationContainerView:UIView,
        startViewController: UIViewController, endViewController: UIViewController,
        snapshotOfEndBackgroundView:UIView, snapshotOfEndIconView:UIView,
        startBackgroundView:UIView, startIconView:UIView,
        endBackgroundView:UIView, endIconView:UIView){
            
            startBackgroundView.hidden = true
            endBackgroundView.hidden = true
            
            startIconView.hidden = true
            endIconView.hidden = true
            
            startViewController.view.backgroundColor = UIColor.clearColor()
            
            animationContainerView.backgroundColor = UIColor.whiteColor()
            animationContainerView.addSubview(endViewController.view)
            animationContainerView.addSubview(snapshotOfEndBackgroundView)
            animationContainerView.addSubview(startViewController.view)
            animationContainerView.addSubview(snapshotOfEndIconView)
            
    }
    
    private func cleanupAfterAnimationUnzoom(
        startViewController: UIViewController, endViewController: UIViewController,
        endViewBackgroundColour:UIColor,
        snapshotOfEndBackgroundView:UIView, snapshotOfEndIconView:UIView,
        startBackgroundView:UIView, startIconView:UIView,
        endBackgroundView:UIView, endIconView:UIView){
            
            endViewController.view.transform = CGAffineTransformIdentity
            
            snapshotOfEndBackgroundView.removeFromSuperview()
            snapshotOfEndIconView.removeFromSuperview()
            
            startBackgroundView.hidden = false
            endBackgroundView.hidden = false
            
            startIconView.hidden = false
            endIconView.hidden = false
            
            endViewController.view.backgroundColor = endViewBackgroundColour
            
    }

    
}
