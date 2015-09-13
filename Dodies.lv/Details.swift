//
//  Details.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import UIKit

class Details : UIViewController {

  var point : DodiesAnnotation!
  
  @IBOutlet weak var pointTitle: UILabel!
  @IBOutlet weak var desc: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pointTitle.text = point.title
    desc.text = point.desc
    
  }
  
  @IBAction func done(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}