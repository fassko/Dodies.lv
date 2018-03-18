//
//  FeatureCollection.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 18/03/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

/// Feature collection
struct FeatureCollection: Codable {
  /// Type
  var type: String
  
  /// Array of features
  var features: [Feature]
}
