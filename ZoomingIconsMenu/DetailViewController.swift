//
//  DetailViewController.swift
//  ZoomingIconsMenu
//
//  Created by asu on 2015-10-01.
//  Copyright © 2015 asu. All rights reserved.
//

import UIKit

class DetailViewController:UIViewController{
    
    @IBAction func backButton(sender: UIButton) {
		navigationController?.popViewControllerAnimated(true)
    }
}
