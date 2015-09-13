//
//  Map.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import CoreLocation
import SwiftyJSON

class Map: UIViewController, MGLMapViewDelegate {

  var mapView: MGLMapView!
  let manager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    if CLLocationManager.authorizationStatus() == .NotDetermined {
      manager.requestAlwaysAuthorization()
    }
    
    // initialize the map view
    mapView = MGLMapView(frame: view.bounds)
    mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    
    mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 57.166,
                                                           longitude: 24.961),
                                    zoomLevel: 5, animated: false)

//    mapView.userTrackingMode = .Follow
    
    view.addSubview(mapView)
    mapView.delegate = self
    
    if CLLocationManager.locationServicesEnabled() {
      mapView.showsUserLocation = true
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    self.loadPlaces()
  }
  
  func loadPlaces () {
      let jsonPath = NSBundle.mainBundle().pathForResource("dati", ofType: "geojson")
      
      let json = JSON(data: NSData(contentsOfFile: jsonPath!)!)
      
      if let features = json["features"].array {
        for feature in features {
          if let feature = feature.dictionary {
            if let geometry = feature["geometry"]?.dictionary {
              if let properties = feature["properties"]?.dictionary {
                let point = MGLPointAnnotation()
                
                if let location = geometry["coordinates"]?.array {
                  point.coordinate = CLLocationCoordinate2DMake(location[1].doubleValue, location[0].doubleValue)
                }
                
                
                
                
                
                point.title = properties["name"]?.string
                point.subtitle = properties["desc"]?.string
                
                

                self.mapView.addAnnotation(point)

              }
            }
          }
        }
      }
  }
  
  func locationManager(manager: CLLocationManager!,
                     didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if (status == .Authorized || status == .AuthorizedWhenInUse) {
      mapView.showsUserLocation = true
    }
  }
 
  
  // Mabox
//  func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
//      var annotationImage = self.mapView.dequeueReusableAnnotationImageWithIdentifier("point")
//      
//      if (annotationImage == nil) {
//          // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
//          let image = UIImage(named: "pisa")
//          annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: "pisa")
//      }
//      
//      return annotationImage
//  }

  func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
    return nil
  }
  
  func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }

}
