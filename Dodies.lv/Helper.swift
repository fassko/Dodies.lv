//
//  Helper.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 31/01/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import Foundation
import UIKit
import GCDKit

import SwiftSpinner
import Localize_Swift

class Helper {
  // MARK: - HUD functions
  
  class func showGlobalProgressHUD() {
    SwiftSpinner.setTitleFont(UIFont(name: "HelveticaNeue", size: 18)!)
    SwiftSpinner.show("Downloading data".localized())
  }
  
  class func dismissGlobalHUD() {
    SwiftSpinner.hide()
  }
}
