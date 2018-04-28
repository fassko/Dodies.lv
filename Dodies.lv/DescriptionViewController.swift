//
//  DescriptionViewController.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 26/03/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import UIKit
import Foundation

import Crashlytics

class DescriptionViewController: UIViewController {

  var point: DodiesAnnotation?

  @IBOutlet weak var descriptionWebView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = point?.title
    navigationItem.titleView = titleLabel

    self.automaticallyAdjustsScrollViewInsets = false
    
    guard let objectUrl = point?.url else { return }
    
    let url = URL(string: "https://dodies.lv/\(objectUrl)")!
    descriptionWebView.loadRequest(URLRequest(url: url))
    descriptionWebView.scrollView.contentOffset = CGPoint(x: 0, y: 0)
  }
}
