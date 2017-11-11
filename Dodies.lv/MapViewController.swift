//
//  Map.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

import Mapbox
import RealmSwift
import Fabric
import Crashlytics
import Localize_Swift
import SwiftSpinner

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {

  /// Map View
  var mapView: MGLMapView!
  
  /// Location manager
  let locationManager = CLLocationManager()
  
  /// Selected point
  var selectedPoint : DodiesAnnotation!
  
  @IBOutlet weak var settingsButton: UIBarButtonItem!
  @IBOutlet weak var aboutButton: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    debugPrint(Realm.Configuration.defaultConfiguration.fileURL!)
    
    if let language = UserDefaults.standard.string(forKey: Constants.languageKey.rawValue) {
      Localize.setCurrentLanguage(language)
    } else {
      Localize.setCurrentLanguage("lv")
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(setUpButtons), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    
    setUpButtons()
    
    navigationItem.titleView = UIImageView(image: UIImage(named: "dodies_nav_logo"))
    
    // ask user to allow location access
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
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
    
    // show loading view
    SwiftSpinner.setTitleFont(UIFont(name: "HelveticaNeue", size: 18)!)
    SwiftSpinner.show("Downloading data".localized())
    
    let realm = try! Realm()
    
    // check if need to update data
    if (realm.objects(DodiesPoint.self).count == 0) {
      downloadData()
    } else {
      DispatchQueue.global(qos: .background).async {
        self.loadPoints(checkForUpdatedData: true)
      }
    }
  }
  
  @objc func setUpButtons() {
    title = "Map".localized()
    settingsButton.title = "Settings".localized()
    aboutButton.title = "About".localized()
  }
  
  override func viewWillAppear(_ animated: Bool) {
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
      
      performSegue(withIdentifier: "details", sender: self)
      
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
    let actionSheet = UIAlertController(title: "Change language".localized(), message: "Please select language".localized(), preferredStyle: .actionSheet)

    let cancelActionButton = UIAlertAction(title: "Cancel".localized(), style: .cancel)
    actionSheet.addAction(cancelActionButton)

    let saveActionButton: UIAlertAction = UIAlertAction(title: "Latvian".localized(), style: .default) { action in
      self.languageChanged(language: "lv")
    }
    actionSheet.addAction(saveActionButton)

    let deleteActionButton: UIAlertAction = UIAlertAction(title: "English".localized(), style: .default){ action in
      self.languageChanged(language: "en")
    }
    actionSheet.addAction(deleteActionButton)
    
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  
  
  // MARK: - Additonal methods
  
  func languageChanged(language:String) {
    if language != UserDefaults.standard.string(forKey: Constants.languageKey.rawValue) {
      UserDefaults.standard.set(language, forKey: Constants.languageKey.rawValue)
      
      Localize.setCurrentLanguage(language)
    
      SwiftSpinner.show("Downloading data".localized())
      
      downloadData()
    }
  }
  
  // download data from server
  func downloadData() {
  
    let language = UserDefaults.getValue(forKey: Constants.languageKey.rawValue, default: "lv")
  
    guard let url = URL(string: "http://dodies.lv/json/\(language).geojson") else { return }
    
    let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
      if let error = error {
        debugPrint("Can't download data \(error) \(language)")
        Answers.logCustomEvent(withName: "CantDownloadData", customAttributes: ["language": language, "error": error])
        self.showError(withMessage: "Can't download data. Please check your settings and try again.".localized())
      } else {
        guard let data = data else { return }
        
        guard let features = try? JSONDecoder().decode(FeatureCollection.self, from: data).features else { return }
        
        let realm = try! Realm()
        
        try! realm.write {
          realm.deleteAll()
        }
        
        features.forEach({ feature in
          let dodiesPoint = DodiesPoint()
          dodiesPoint.latitude = feature.geometry.coordinates[0]
          dodiesPoint.longitude = feature.geometry.coordinates[1]

          let properties = feature.properties
          dodiesPoint.name = properties.name
          dodiesPoint.tips = properties.tips
          dodiesPoint.st = properties.st
          dodiesPoint.km = properties.km
          dodiesPoint.txt = properties.txt
          dodiesPoint.dat = properties.dat
          dodiesPoint.img = properties.img
          dodiesPoint.url = properties.url

          // write in realm database
          try! realm.write {
            realm.add(dodiesPoint)
          }
        })
        
        self.checkLastChangedDate(update: false)
        
        DispatchQueue.main.async {
          self.removeAllAnnotations()
          self.loadPoints()
        }
      }
    })
    
    task.resume()
  }
  
  // remove all annotation from mapview
  func removeAllAnnotations() {
    guard let annotations = mapView.annotations else { return }
    
    mapView.removeAnnotations(annotations)
}
  
  // load points from realm database
  func loadPoints(checkForUpdatedData:Bool = false) {
    
    let realm = try! Realm()
    
    let points = realm.objects(DodiesPoint.self)
    
    points.forEach({ p in
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
      point.url = p.url
      
      self.mapView.addAnnotation(point)
    })
    
    DispatchQueue.main.async {
      SwiftSpinner.hide()
      
      if checkForUpdatedData {
        self.checkLastChangedDate(update: true)
      }
    }
  }
  
  // check if need to update
  func checkLastChangedDate(update: Bool) {
    guard let url = URL(string: "http://dodies.lv/apraksti/lastchanged.txt") else { return }
    
    let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
      if let error = error {
        debugPrint("Can't get last changed date \(error)")
      }
      
      guard let data = data else { return }
      
      guard let lastChangedDate = String(data: data, encoding: .utf8) else { return }
      
      guard let timestamp = Int(lastChangedDate.replacingOccurrences(of: "\n", with: "")) else { return }
      
      if update, timestamp > UserDefaults.standard.integer(forKey: Constants.lastChangedTimestampKey.rawValue) {
        self.downloadData()
      } else {
        UserDefaults.standard.set(timestamp, forKey: Constants.lastChangedTimestampKey.rawValue)
      }
    })
    
    task.resume()
  }
  
  // show error
  func showError(withMessage message: String) {
    let alert = UIAlertController(title: "Dodies.lv", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  // pass object to details view
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "details" || segue.identifier == "detailsWithPicture" {
    
      if let details: DetailsViewController = segue.destination as? DetailsViewController {
        details.point = selectedPoint
        
        selectedPoint = nil
      }
    }
  }

}
