//
//  ZoomingIconCell.swift
//  ZoomingIconsMenu
//
//  Created by asu on 2015-10-01.
//  Copyright © 2015 asu. All rights reserved.
//

import UIKit

class ZoomingIconCell:UICollectionViewCell{
    
    @IBOutlet weak var backgroundColourView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColourView.layer.cornerRadius = bounds.width/2.0
        backgroundColourView.layer.masksToBounds = true
    }

}
