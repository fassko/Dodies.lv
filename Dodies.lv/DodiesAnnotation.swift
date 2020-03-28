//
//  Path.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import MapKit

enum PointType: String {
  case trail
  case tower
  case picnic
}

class DodiesAnnotation: NSObject, MKAnnotation, UIAccessibilityIdentification {
  var accessibilityIdentifier: String?
  
  let coordinate: CLLocationCoordinate2D
  
  var color: UIColor {
    return {
      switch type {
      case .trail:
        return Constants.trailColor
      case .tower:
        return Constants.towerColor
      case .picnic:
        return Constants.picnicColor
      }
      }()
  }
  
  var type: PointType
  
  public var title: String? {
    return name
  }
  
  var name: String
  var tips: String
  var km: String
  var dat: String
  var url: String
  var img: String
  
  init(latitude: Double,
       longitude: Double,
       name: String,
       tips: String,
       st: String,
       km: String,
       dat: String,
       url: String,
       img: String) {
    
    self.name = name
    self.tips = tips
    self.dat = dat
    self.km = km
    self.url = url
    self.img = img
    
    switch tips {
    case "tornis":
      type = .tower
    case "pikniks":
      type = .picnic
    default:
      type = .trail
    }
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    accessibilityIdentifier = name
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
