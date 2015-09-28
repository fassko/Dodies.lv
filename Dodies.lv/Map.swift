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
import SwiftCSV
import Alamofire

class Map: UIViewController, MGLMapViewDelegate {

  var mapView: MGLMapView!
  let manager = CLLocationManager()
  var selectedPoint : DodiesAnnotation!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
    let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
    
    Alamofire.download(.GET, "http://dodies.lv/apraksti/dati.csv", destination: destination)
         .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
             print(totalBytesRead)

             // This closure is NOT called on the main queue for performance
             // reasons. To update your ui, dispatch to the main queue.
             dispatch_async(dispatch_get_main_queue()) {
                 print("Total bytes read on main queue: \(totalBytesRead)")
             }
         }.responseString { response in
          print(response)
         }
    
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
    
      var csv: CSV!
      var error: NSErrorPointer = nil
    
      let csvURL = NSBundle.mainBundle().URLForResource("dati", withExtension: "csv")
      
      do {
        csv = try CSV(contentsOfURL: csvURL!)
      } catch let error1 as NSError {
        error.memory = error1
        csv = nil
      }

    
      for item in csv.rows {
        let point = DodiesAnnotation()
        
        let latitude = NSNumberFormatter().numberFromString(self.replaceDoubleQuotes(item["\"latitude\""]!)!)?.doubleValue
        let longitude = NSNumberFormatter().numberFromString(self.replaceDoubleQuotes(item["\"longitude\""]!)!)?.doubleValue

        
//        print(item)
        
        if (longitude != nil && latitude != nil) {
          point.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        }
        
        point.title = self.replaceDoubleQuotes(item["\"name\""]!)
        point.desc = self.replaceDoubleQuotes(item["\"desc\""]!)!
        point.tips = self.replaceDoubleQuotes(item["\"tips\""]!)!
        point.samaksa = self.replaceDoubleQuotes(item["\"samaksa\""]!)!
        point.statuss = self.replaceDoubleQuotes(item["\"statuss\""]!)!
        point.vertejums = self.replaceDoubleQuotes(item["\"vertejums\""]!)!
        point.klase = self.replaceDoubleQuotes(item["\"klase\""]!)!
        point.garums = self.replaceDoubleQuotes(item["\"garums\""]!)!
        point.symb = self.replaceDoubleQuotes(item["\"symb\""]!)!
        point.symb = self.replaceDoubleQuotes(item["\"symb\""]!)!
        point.id = self.replaceDoubleQuotes(item["\"id\""]!)!
        
        dispatch_async(dispatch_get_main_queue(), {
          [unowned self] in
          self.mapView.addAnnotation(point)
        })
      }
    })
  }
  
  func replaceDoubleQuotes (value: String) -> String? {
    return value.stringByReplacingOccurrencesOfString("\"", withString: "")
  }
  
  func locationManager(manager: CLLocationManager!,
                     didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if (status == .Authorized || status == .AuthorizedWhenInUse) {
      mapView.showsUserLocation = true
    }
  }
 
  
  // Mabox
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
