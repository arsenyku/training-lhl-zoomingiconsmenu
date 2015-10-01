//
//  MenuViewController.swift
//  ZoomingIconsMenu
//
//  Created by asu on 2015-10-01.
//  Copyright © 2015 asu. All rights reserved.
//

import UIKit

class MenuViewController: UICollectionViewController, ZoomingIconViewController{

    var cellForTransition:ZoomingIconCell?
    
    override func viewDidLoad() {
        collectionView!.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        
    }
    
    // MARK: - UICollectionViewControllerDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch (section){
        case 0:
            return 2
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("zoomingIconCell", forIndexPath: indexPath)
    	
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let controller = UIStoryboard(name: "DetailView", bundle: nil)
            .instantiateViewControllerWithIdentifier("detailViewController")
            as! DetailViewController
        
        cellForTransition = (collectionView.cellForItemAtIndexPath(indexPath) as! ZoomingIconCell)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        // Center the items in each section. 
        // To do this, override the section inset on a per section basis and compute
        // the left and right inset necessary to introduce horizontal spacing.
        let numberOfCells = self.collectionView(collectionView, numberOfItemsInSection: section)
        let widthOfCells = CGFloat(numberOfCells) * layout.itemSize.width + CGFloat(numberOfCells-1) * layout.minimumInteritemSpacing
        
        let inset = (collectionView.bounds.width - widthOfCells) / 2.0
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 40, right: inset)
    }
    
    // MARK: ZoomingIconViewController
    
    func zoomingIconBackgroundColourViewForTransition(transition: ZoomingIconTransition) -> UIView? {
        return cellForTransition?.backgroundColourView
    }
    func zoomingIconImageViewForTransition(transition: ZoomingIconTransition) -> UIImageView? {
     	return cellForTransition?.iconImageView
    }

}
