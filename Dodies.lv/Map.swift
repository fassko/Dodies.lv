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
  var selectedPoint : DodiesAnnotation!

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
    
    var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.loadPlaces()
        })
  }
  
  
  func loadPlaces () {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      let jsonPath = NSBundle.mainBundle().pathForResource("dati", ofType: "geojson")
      
      let json = JSON(data: NSData(contentsOfFile: jsonPath!)!)
      
      if let features = json["features"].array {
        for feature in features {
          if let feature = feature.dictionary {
            if let geometry = feature["geometry"]?.dictionary {
              if let properties = feature["properties"]?.dictionary {
                let point = DodiesAnnotation()
                
                if let location = geometry["coordinates"]?.array {
                  point.coordinate = CLLocationCoordinate2DMake(location[1].doubleValue, location[0].doubleValue)
                }
                
                point.title = properties["name"]?.string
                point.desc = (properties["desc"]?.string)!
                point.symb = (properties["symb"]?.string)!
                
                dispatch_async(dispatch_get_main_queue(), {
                  [unowned self] in
                  self.mapView.addAnnotation(point)
                })
              }
            }
          }
        }
      }
    })
  }
  
  func locationManager(manager: CLLocationManager!,
                     didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if (status == .Authorized || status == .AuthorizedWhenInUse) {
      mapView.showsUserLocation = true
    }
  }
 
  
  // Mabox
  func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
    return nil
  }
  
  func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
    return UIButton.init(type: UIButtonType.InfoLight)
  }
  
  func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
    selectedPoint = annotation as! DodiesAnnotation
    if selectedPoint != nil {
      
      performSegueWithIdentifier("details", sender: self)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "details" {
    
      if let details: Details = segue.destinationViewController as? Details {
        details.point = selectedPoint
        
        selectedPoint = nil
      }
    }
  }
  
  
  func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }

}
