//
//  Feature.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 18/03/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

/// Feature object
struct Feature: Codable {
  /// Type
  var type: String
  
  /// Feture properties
  var properties: Property
  
  /// Geometry
  var geometry: Geometry
}
