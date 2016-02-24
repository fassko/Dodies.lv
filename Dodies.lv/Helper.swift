//
//  Helper.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 31/01/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import Foundation
import UIKit

import MBProgressHUD

class Helper {
  // MARK: - HUD functions
  
  class func showGlobalProgressHUD() {
    if let window = UIApplication.sharedApplication().delegate?.window {
      let hud = MBProgressHUD.showHUDAddedTo(window, animated: true)
      hud.labelText = "Ielādē datus"
      hud.userInteractionEnabled = false
      hud.layer.zPosition = 2
      hud.labelFont = UIFont(name: "HelveticaNeue-Medium", size: 18)
    }
  }
  
  class func dismissGlobalHUD() {
    if let window = UIApplication.sharedApplication().delegate?.window  {
      MBProgressHUD.hideAllHUDsForView(window, animated: true)
    }
  }
}