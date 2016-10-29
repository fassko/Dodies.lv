//
//  DescriptionViewController.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 26/03/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import UIKit
import Foundation
import Attributed
import Fabric
import Crashlytics
import LKAlertController


class DescriptionViewController: UIViewController {

  var point : DodiesAnnotation!

  @IBOutlet weak var descriptionWebView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = point.title
    
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
    titleLabel.backgroundColor = UIColor.clear
    titleLabel.font = UIFont(name: "HelveticaNeue-Medium",  size: 18)
    titleLabel.textAlignment = NSTextAlignment.center
    titleLabel.text = self.title
    titleLabel.textColor = UIColor.white
    titleLabel.adjustsFontSizeToFitWidth = true
    
    self.navigationItem.titleView = titleLabel

    
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    descriptionWebView.loadRequest(NSURLRequest(url: NSURL(string: "http://dodies.lv/obj/\(point.url)")! as URL) as URLRequest)
    descriptionWebView.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    
  }
}
