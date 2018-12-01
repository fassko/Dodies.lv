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

class DodiesAnnotationView: MKMarkerAnnotationView {
  override func prepareForDisplay() {
    super.prepareForDisplay()
    displayPriority = .defaultHigh
    canShowCallout = true
    rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
  }
}

class TrailAnnotationView: DodiesAnnotationView {
  static let ReuseID = PointType.trail.rawValue

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    clusteringIdentifier = PointType.trail.rawValue
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    markerTintColor = Constants.trailColor
    glyphImage = #imageLiteral(resourceName: "trail")
  }
}

class TowerAnnotationView: DodiesAnnotationView {
  static let ReuseID = PointType.tower.rawValue
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    clusteringIdentifier = PointType.tower.rawValue
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    displayPriority = .defaultLow
    markerTintColor = Constants.towerColor
    glyphImage = #imageLiteral(resourceName: "binoculars")
  }
}

class PicnicAnnotationView: DodiesAnnotationView {
  static let ReuseID = PointType.picnic.rawValue
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    clusteringIdentifier = PointType.picnic.rawValue
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    displayPriority = .defaultLow
    markerTintColor = Constants.picnicColor
    glyphImage = #imageLiteral(resourceName: "picnic-table")
  }
}

class DodiesAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  
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
  
  var latitude: Double
  var longitude: Double
  var name: String
  var tips: String
  var km: String
  var txt: String
  var dat: String
  var url: String
  
  init(latitude: Double, longitude: Double,
       name: String, tips: String,
       st: String, km: String,
       txt: String, dat: String,
       url: String) {
    
    self.latitude = latitude
    self.longitude = longitude
    self.name = name
    self.tips = tips
    self.dat = dat
    self.km = km
    self.url = url
    self.txt = txt
    
    switch tips {
    case "tornis":
      type = .tower
    case "piknins":
      type = .picnic
    default:
      type = .trail
    }
    
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
