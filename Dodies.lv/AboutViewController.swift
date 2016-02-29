//
//  AboutViewController.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/02/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.titleView = UIImageView(image: UIImage(named: "dodies_nav_logo"))
    
    self.automaticallyAdjustsScrollViewInsets = false
  }
  
  @IBAction func openDodiesLv(sender: AnyObject) {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://dodies.lv/par.php")!)
  }
  
}
