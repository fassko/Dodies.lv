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
import Fabric
import Crashlytics
import FontAwesome_swift
import Localize_Swift

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
    
    self.setLanguage()
    
    self.title = "Map".localized()
    
    navigationItem.titleView = UIImageView(image: UIImage(named: "dodies_nav_logo"))
    
    let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20)] as Dictionary!
    aboutButton.setTitleTextAttributes(attributes, for: .normal)
    aboutButton.title = String.fontAwesomeIcon(name: .question)
    
    settingsButton.setTitleTextAttributes(attributes, for: .normal)
    settingsButton.title = String.fontAwesomeIcon(name: .language)
    
    // ask user to allow location access
    if CLLocationManager.authorizationStatus() == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
    
    // initialize the map view
    let styleURL = NSURL(string: "mapbox://styles/normis/cilzp6g1h00grbjlwwsh52vig")
    mapView = MGLMapView(frame: view.bounds, styleURL: styleURL as URL?)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    mapView.setVisibleCoordinateBounds(MGLCoordinateBounds(sw: CLLocationCoordinate2D(latitude: 55.500, longitude: 20.500), ne: CLLocationCoordinate2D(latitude: 58.500, longitude: 28.500)), animated: false)

    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.isRotateEnabled = false
    
    mapView.attributionButton.isHidden = true
    
    view.addSubview(mapView)
    
    // print Realm database path
//    print(Realm.Configuration.defaultConfiguration.path!)
    
    // show loading view
    Helper.showGlobalProgressHUD()
    
    let realm = try! Realm()
    
    // check if need to update data
    if (realm.objects(DodiesPoint.self).count == 0) {
      downloadData()
    } else {
      Async.background {
        self.loadPoints(checkForUpdatedData: true)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker?.set(kGAIScreenName, value: "Map")
    
    var eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
    tracker?.send(eventTracker as! [NSObject : AnyObject])
    
    Answers.logContentView(withName: "Map", contentType: "Map", contentId: nil, customAttributes: nil)
  }
  
  
  // MARK: - Mapbox implementation
  
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
  
    do {
  
      selectedPoint = annotation as! DodiesAnnotation

      var icon = selectedPoint.tips
      
      if selectedPoint.st == "parbaudits" {
        icon = "\(icon)-active"
      } else {
        icon = "\(icon)-disabled"
      }
      
      var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: icon)
          
      if annotationImage == nil {
        let image = UIImage(named: icon)
        annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: icon)
      }
      
      return annotationImage
    }
  }
  
  func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    return UIButton.init(type: UIButtonType.infoLight)
  }
  
  func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
    if let point = annotation as? DodiesAnnotation {
      selectedPoint = point
      
      if !point.img.isEmpty {
        performSegue(withIdentifier: "detailsWithPicture", sender: self)
      } else {
        performSegue(withIdentifier: "details", sender: self)
      }
      
      mapView.deselectAnnotation(annotation, animated: true)
    }
  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    if annotation.isKind(of: DodiesAnnotation.self) {
      return true
    }
    
    return false
  }
  
  
  // MARK: - Interface methods
  
  @IBAction func setLanguage(sender: AnyObject) {
    let actionSheet: UIAlertController = UIAlertController(title: "Change language".localized(), message: "Please select language".localized(), preferredStyle: .actionSheet)

    let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel".localized(), style: .cancel) { action -> Void in
      
    }
    actionSheet.addAction(cancelActionButton)

    let saveActionButton: UIAlertAction = UIAlertAction(title: "Latvian".localized(), style: .default){
      action -> Void in
        self.languageChanged(language: "lv")
    }
    actionSheet.addAction(saveActionButton)

    let deleteActionButton: UIAlertAction = UIAlertAction(title: "English".localized(), style: .default){
      action -> Void in
        self.languageChanged(language: "en")
    }
    actionSheet.addAction(deleteActionButton)
    
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  
  
  // MARK: - Additonal methods
  
  func setLanguage() {
    
    if let language = Defaults[self.languageKey].string {
      Localize.setCurrentLanguage(language)
    } else {
      Localize.setCurrentLanguage("lv")
    }
  }
  
  func languageChanged(language:String) {
    if language != Defaults[self.languageKey].stringValue {
      Defaults[self.languageKey] = language
      
      Localize.setCurrentLanguage(language)
      
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
  
    Alamofire.request("http://dodies.lv/json/\(language!).geojson").responseJSON(completionHandler: {
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
    
    let points = realm.objects(DodiesPoint.self)
    
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
    Alamofire.request("http://dodies.lv/apraksti/lastchanged.txt").responseString(completionHandler: {response in
      if response.result.isSuccess {
          if let timestamp = Int(response.result.value!.replacingOccurrences(of: "\n", with: "")) {
            Defaults[self.LastChangedTimestampKey] = timestamp
          }
        }
    })
  }
  
  // check if need to update
  func checkIfNeedToUpdate() {

    Alamofire.request("http://dodies.lv/apraksti/lastchanged.txt").responseString(completionHandler: {
  response in
      if response.result.isSuccess {
        if let timestamp = Int(response.result.value!.replacingOccurrences(of: "\n", with: "")) {
          if timestamp > Defaults[self.LastChangedTimestampKey].intValue {
            self.downloadData()
          }
        }
      }
    })
  }
  
  // show error
  func showError() {
    let alert = UIAlertController(title: "Error".localized(), message: "Can't download data. Please check your settings and try again.".localized(), preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  // pass object to details view
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "details" || segue.identifier == "detailsWithPicture" {
    
      if let details: Details = segue.destination as? Details {
        details.point = selectedPoint
        
        selectedPoint = nil
      }
    }
  }

}
