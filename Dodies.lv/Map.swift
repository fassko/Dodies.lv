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
import Alamofire
import RealmSwift

class Map: UIViewController, MGLMapViewDelegate {

  var mapView: MGLMapView!
  let manager = CLLocationManager()
  var selectedPoint : DodiesAnnotation!
  
  var realm = try! Realm()

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

    mapView.delegate = self
    mapView.showsUserLocation = true
    
    view.addSubview(mapView)
    
//    realm = try! Realm()
    
    downloadData()
  }
  
  
  // MARK: - Mapbox implementation
  
  func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
  
    selectedPoint = annotation as! DodiesAnnotation

    var annotation = ""
    
    switch selectedPoint.tips {
      case "taka":
        annotation = "taka"
        break
      
      case "parks":
        annotation = "parks"
        break
      
      case "tornis":
        annotation = "tornis"
        break
      
      case "piknins":
        annotation = "piknins"
        break
      
      default:
        annotation = "taka"
        break
    }
    
  
    var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(annotation)
        
    if annotationImage == nil {
        let image = UIImage(named: annotation)
        annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: annotation)
    }
    
    return annotationImage
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
  

  func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  
  // MARK: - Additonal methods
  
  func downloadData() {
    Alamofire.request(.GET, "http://dodies.lv/apraksti/dati.geojson").responseJSON(completionHandler: {
      response in
      
      let json = JSON(response.result.value!)
      
      try! self.realm.write {
        self.realm.deleteAll()
      }
      
      for feature in json["features"].arrayValue {
        
        let coordinates:Array<Double> = feature["geometry"].dictionaryValue["coordinates"]?.arrayObject as! Array<Double>
        let properties = feature["properties"].dictionaryValue
        
        
        let dodiesPoint = DodiesPoint()
        dodiesPoint.latitude = coordinates[0]
        dodiesPoint.longitude = coordinates[1]
        
        dodiesPoint.apraksts = properties["apraksts"]!.stringValue
        dodiesPoint.datums = properties["datums"]!.stringValue
        dodiesPoint.desc = properties["desc"]!.stringValue
        dodiesPoint.garums = properties["garums"]!.stringValue
        dodiesPoint.id = properties["id"]!.stringValue
        dodiesPoint.klase = properties["klase"]!.stringValue
        dodiesPoint.name = properties["name"]!.stringValue
        dodiesPoint.samaksa = properties["samaksa"]!.stringValue
        dodiesPoint.statuss = properties["statuss"]!.stringValue
        dodiesPoint.symb = properties["symb"]!.stringValue
        dodiesPoint.tips = properties["tips"]!.stringValue

        try! self.realm.write {
          self.realm.add(dodiesPoint)
        }
      }
      
      self.loadPoints()
      
      
    })
  }
  
  func loadPoints() {
    
    let points = realm.objects(DodiesPoint)
    
    for p:DodiesPoint in points {
      let point = DodiesAnnotation()
        
        point.coordinate = CLLocationCoordinate2DMake(p.longitude, p.latitude)

        point.title = p.name
        point.desc = p.desc
        point.tips = p.tips
        point.samaksa = p.samaksa
        point.statuss = p.statuss
        point.vertejums = p.vertejums
        point.klase = p.klase
        point.garums = p.garums
        point.symb = p.symb
        point.id = p.id
      
        self.mapView.addAnnotation(point)
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

}
