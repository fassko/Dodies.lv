//
//  Geometry.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 18/03/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

/// Feature geometry (coordinates)
struct Geometry: Codable {
  /// Type
  var type: String
  
  /// Coordinates array (0: longitude, 1: latitude)
  var coordinates: [Double]
}
