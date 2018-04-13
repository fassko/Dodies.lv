//
//  Property.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 18/03/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

/// Feature properties
struct Property: Codable {
  
  /// Name
  var name: String
  
  /// Type
  var tips: String
  
  /// Status
  var st: String
  
  /// Lenght in km
  var km: String
  
  /// Description
  var txt: String
  
  /// Date when checked
  var dat: String
  
  /// Picture
  var img: String
  
  /// Large picture
  var img2: String
  
  /// Url of description
  var url: String
}
