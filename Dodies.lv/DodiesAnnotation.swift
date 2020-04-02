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
  var km: String
  var checkedDate: String
  var url: String
  var img: String
  
  init(latitude: Double,
       longitude: Double,
       name: String,
       type: String,
       st: String,
       km: String,
       checkedDate: String,
       url: String,
       img: String) {
    
    self.name = name
    self.checkedDate = checkedDate
    self.km = km
    self.url = url
    self.img = img
    
    self.type = .picnic
    
    switch type {
    case "tornis":
      self.type = .tower
    case "pikniks":
      self.type = .picnic
    default:
      self.type = .trail
    }
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    accessibilityIdentifier = name
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
