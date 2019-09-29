//
//  Constants.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 07/10/2017.
//  Copyright © 2017 fassko. All rights reserved.
//

import Foundation
import UIKit

enum Constants {
  static let lastChangedTimestampKey = "LastChangedTimestamp"
  static let languageKey = "language"
  
  static let greenColor = UIColor(named: "dodies-green")
  static let lightGreen = UIColor(named: "light-green")
  
  static let trailColor = #colorLiteral(red: 0.9960784314, green: 0.7882352941, blue: 0.3568627451, alpha: 1)
  static let towerColor = #colorLiteral(red: 0.3960784314, green: 0.7058823529, blue: 0.7333333333, alpha: 1)
  static let picnicColor = #colorLiteral(red: 0.9294117647, green: 0.4196078431, blue: 0.003921568627, alpha: 1)
  
  static let trailImage = #imageLiteral(resourceName: "signpost")
  static let towerImage = #imageLiteral(resourceName: "binoculars.pdf")
  static let picnicImage = #imageLiteral(resourceName: "picnic-table")
}
