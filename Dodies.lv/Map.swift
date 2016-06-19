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
import SwiftyUserDefaults
import Async
import SDCAlertView
import Fabric
import Crashlytics
import FontAwesome_swift

class Map: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {

  var mapView: MGLMapView!
  let manager = CLLocationManager()
  var selectedPoint : DodiesAnnotation!
  
  let LastChangedTimestampKey = "LastChangedTimestamp"
  let languageKey = "language"
  
  @IBOutlet weak var settingsButton: UIBarButtonItem!
  @IBOutlet weak var aboutButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Karte"
    
    navigationItem.titleView = UIImageView(image: UIImage(named: "dodies_nav_logo"))
    
    let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
    aboutButton.setTitleTextAttributes(attributes, forState: .Normal)
    aboutButton.title = String.fontAwesomeIconWithName(.Question)
    
    settingsButton.setTitleTextAttributes(attributes, forState: .Normal)
    settingsButton.title = String.fontAwesomeIconWithName(.Language)
    
    // ask user to allow location access
    if CLLocationManager.authorizationStatus() == .NotDetermined {
      manager.requestWhenInUseAuthorization()
    }
    
    // initialize the map view
    let styleURL = NSURL(string: "mapbox://styles/normis/cilzp6g1h00grbjlwwsh52vig")
    mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
    mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    
    mapView.setVisibleCoordinateBounds(MGLCoordinateBounds(sw: CLLocationCoordinate2D(latitude: 55.500, longitude: 20.500), ne: CLLocationCoordinate2D(latitude: 58.500, longitude: 28.500)), animated: false)

    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.rotateEnabled = false
    
    mapView.attributionButton.hidden = true
    
    view.addSubview(mapView)
    
    // print Realm database path
//    print(Realm.Configuration.defaultConfiguration.path!)
    
    // show loading view
    Helper.showGlobalProgressHUD()
    
    let realm = try! Realm()
    
    // check if need to update data
    if (realm.objects(DodiesPoint).count == 0) {
      downloadData()
    } else {
      Async.background {
        self.loadPoints(true)
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Map")
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
    
    Answers.logContentViewWithName("Map", contentType: "Map", contentId: nil, customAttributes: nil)
  }
  
  
  // MARK: - Mapbox implementation
  
  func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
  
    do {
  
      selectedPoint = annotation as! DodiesAnnotation

      var icon = selectedPoint.tips
      
      if selectedPoint.st == "parbaudits" {
        icon = "\(icon)-active"
      } else {
        icon = "\(icon)-disabled"
      }
      
      var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(icon)
          
      if annotationImage == nil {
        let image = UIImage(named: icon)
        annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: icon)
      }
      
      return annotationImage
    }
  }
  
  func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
    return UIButton.init(type: UIButtonType.InfoLight)
  }
  
  func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
    if let point = annotation as? DodiesAnnotation {
      selectedPoint = point
      
      if !point.img.isEmpty {
        performSegueWithIdentifier("detailsWithPicture", sender: self)
      } else {
        performSegueWithIdentifier("details", sender: self)
      }
      
      mapView.deselectAnnotation(annotation, animated: true)
    }
  }
  
  func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    if annotation.isKindOfClass(DodiesAnnotation) {
      return true
    }
    
    return false
  }
  
  
  // MARK: - Interface methods
  
  @IBAction func setLanguage(sender: AnyObject) {
    let actionSheet: UIAlertController = UIAlertController(title: "Change the language", message: "Please select the language", preferredStyle: .ActionSheet)

    let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
      
    }
    actionSheet.addAction(cancelActionButton)

    let saveActionButton: UIAlertAction = UIAlertAction(title: "Latviešu", style: .Default){
      action -> Void in
        self.languageChanged("lv")
    }
    actionSheet.addAction(saveActionButton)

    let deleteActionButton: UIAlertAction = UIAlertAction(title: "English", style: .Default){
      action -> Void in
        self.languageChanged("en")
    }
    actionSheet.addAction(deleteActionButton)
    
    self.presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  
  
  // MARK: - Additonal methods
  
  func languageChanged(language:String) {
    if language != Defaults[self.languageKey].stringValue {
      Defaults[self.languageKey] = language
      
      Helper.showGlobalProgressHUD()
      
      self.downloadData()
    }
  }
  
  // download data from server
  func downloadData() {
  
    var language = Defaults[self.languageKey].string
    
    if language == nil {
      language = "lv"
    }
  
    Alamofire.request(.GET, "http://dodies.lv/json/\(language!).geojson").responseJSON(completionHandler: {
      response in
      
        Helper.dismissGlobalHUD()
      
        if response.result.isFailure {
          Crashlytics.logEvent("CantDownloadData", attributes: ["url": "http://dodies.lv/json/\(language!).geojson", "error": (response.result.error?.localizedDescription)!])
          self.showError()
        }
      
        if response.result.isSuccess {
        
          if let value = response.result.value {
            let json = JSON(value)
            
            if let features = json["features"].array {
            
              let realm = try! Realm()
          
              try! realm.write {
                realm.deleteAll()
              }
              
              for feature in features {
                
                let coordinates:Array<Double> = feature["geometry"].dictionaryValue["coordinates"]?.arrayObject as! Array<Double>
                
                if let properties = feature["properties"].dictionary {
                
                  let dodiesPoint = DodiesPoint()
                  dodiesPoint.latitude = coordinates[0]
                  dodiesPoint.longitude = coordinates[1]
                  
                  dodiesPoint.name = properties["name"]!.stringValue
                  dodiesPoint.tips = properties["tips"]!.stringValue
                  dodiesPoint.st = properties["st"]!.stringValue
                  dodiesPoint.km = properties["km"]!.stringValue
                  dodiesPoint.txt = properties["txt"]!.stringValue
                  dodiesPoint.dat = properties["dat"]!.stringValue
                  dodiesPoint.img = properties["img"]!.stringValue
                  dodiesPoint.img2 = properties["img2"]!.stringValue
                  dodiesPoint.url = properties["url"]!.stringValue

                  // write in realm database
                  try! realm.write {
                    realm.add(dodiesPoint)
                  }
                } else {
                  
                }
              }
              
              self.updateLastChangedTimestamp()
              self.removeAllAnnotations()
              self.loadPoints()
            }
          }
        }
    })
  }
  
  // remove all annotation from mapview
  func removeAllAnnotations() {
    if self.mapView.annotations != nil {
      let annotations = self.mapView.annotations!.filter {
          $0 !== self.mapView.userLocation
      }
      self.mapView.removeAnnotations(annotations)
    }
}
  
  // load points from realm database
  func loadPoints(checkForUpdatedData:Bool = false) {
    
    let realm = try! Realm()
    
    let points = realm.objects(DodiesPoint)
    
    for p:DodiesPoint in points {
      let point = DodiesAnnotation()
        
        point.coordinate = CLLocationCoordinate2DMake(p.longitude, p.latitude)
        point.title = p.name

        point.name = p.name
        point.tips = p.tips
        point.st = p.st
        point.km = p.km
        point.txt = p.txt
        point.dat = p.dat
        point.img = p.img
        point.img2 = p.img2
        point.url = p.url
      
      self.mapView.addAnnotation(point)
    }
    
    Async.main {
      Helper.dismissGlobalHUD()
      
      if checkForUpdatedData {
        self.checkIfNeedToUpdate()
      }
    }
  }
  
  // update last changed timestamp from server
  func updateLastChangedTimestamp() {
    Alamofire.request(.GET, "http://dodies.lv/apraksti/lastchanged.txt").responseString(completionHandler: {
      response in
        if response.result.isSuccess {
          if let timestamp = Int(response.result.value!.stringByReplacingOccurrencesOfString("\n", withString: "")) {
            Defaults[self.LastChangedTimestampKey] = timestamp
          }
        }
    })
  }
  
  // check if need to update
  func checkIfNeedToUpdate() {

    Alamofire.request(.GET, "http://dodies.lv/apraksti/lastchanged.txt").responseString(completionHandler: {
  response in
      if response.result.isSuccess {
        if let timestamp = Int(response.result.value!.stringByReplacingOccurrencesOfString("\n", withString: "")) {
          if timestamp > Defaults[self.LastChangedTimestampKey].intValue {
            self.downloadData()
          }
        }
      }
    })
  }
  
  // show error
  func showError() {
    let alert = AlertController(title: "Kļūda", message: "Neizdevās lejuplādēt datus, lūdzu pārbaudiet savus iestatījumus un mēģiniet vēlreiz!", preferredStyle: .Alert)
          alert.addAction(AlertAction(title: "OK", style: .Preferred))
          alert.present()
  }
  
  // pass object to details view
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "details" || segue.identifier == "detailsWithPicture" {
    
      if let details: Details = segue.destinationViewController as? Details {
        details.point = selectedPoint
        
        selectedPoint = nil
      }
    }
  }

}
