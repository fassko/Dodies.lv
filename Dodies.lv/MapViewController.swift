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

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, Storyboarded {
  
  weak var coordinator: MainCoordinator?

  /// Map View
  var mapView: MGLMapView!
  
  /// Location manager
  let locationManager = CLLocationManager()
  
  /// Selected point
  var selectedPoint: DodiesAnnotation!
  
  var pointDetails: DodiesPointDetails!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    debugPrint(Realm.Configuration.defaultConfiguration.fileURL!)
    
    if let language = UserDefaults.standard.string(forKey: Constants.languageKey.rawValue) {
      Localize.setCurrentLanguage(language)
    } else {
      Localize.setCurrentLanguage("lv")
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(setUpButtons),
                                           name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    
    navigationItem.titleView = UIImageView(image: UIImage(named: "dodies_nav_logo"))
    
    // ask user to allow location access
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    
    // initialize the map view
    let styleURL = URL(string: "mapbox://styles/normis/cilzp6g1h00grbjlwwsh52vig")
    mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    let swCoordinate = CLLocationCoordinate2D(latitude: 55.500, longitude: 20.500)
    let neCoordinate = CLLocationCoordinate2D(latitude: 58.500, longitude: 28.500)
    let visibleCoordinateBounds = MGLCoordinateBounds(sw: swCoordinate, ne: neCoordinate)
    mapView.setVisibleCoordinateBounds(visibleCoordinateBounds, animated: false)
    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.isRotateEnabled = false
    mapView.attributionButton.isHidden = true
    view.addSubview(mapView)
    
    // show loading view
    SwiftSpinner.setTitleFont(UIFont(name: "HelveticaNeue", size: 18)!)
    SwiftSpinner.show("Downloading data".localized())
    
    do {
      let realm = try Realm()
      
      // check if need to update data
      if realm.objects(DodiesPoint.self).count == 0 {
        downloadData()
      } else {
        DispatchQueue.global(qos: .background).async {
          self.loadPoints(checkForUpdatedData: true)
        }
      }
    } catch {
      print("Can't load points from Realm")
    }
    
    let aboutButton = UIBarButtonItem(title: "About".localized(),
                                      style: .plain,
                                      target: self,
                                      action: #selector(about(sender:)))
    navigationItem.rightBarButtonItem = aboutButton
    
    let settingsButton = UIBarButtonItem(title: "Settings".localized(),
                                         style: .plain,
                                         target: self,
                                         action: #selector(setLanguage(sender:)))
    navigationItem.leftBarButtonItem = settingsButton
  }
  
  @objc func setUpButtons() {
    title = "Map".localized()
    navigationItem.leftBarButtonItem?.title = "Settings".localized()
    navigationItem.rightBarButtonItem?.title = "About".localized()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    Answers.logContentView(withName: "Map", contentType: "Map", contentId: nil, customAttributes: nil)
  }
  
  // MARK: - Interface methods
  @IBAction func about(sender: AnyObject) {
    coordinator?.showAbout()
  }
  
  @IBAction func setLanguage(sender: AnyObject) {
    let actionSheet = UIAlertController(title: "Change language".localized(),
                                        message: "Please select language".localized(),
                                        preferredStyle: .actionSheet)
    
    actionSheet.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem

    let cancelActionButton = UIAlertAction(title: "Cancel".localized(), style: .cancel)
    actionSheet.addAction(cancelActionButton)

    let saveActionButton: UIAlertAction = UIAlertAction(title: "Latvian".localized(), style: .default) { _ in
      self.languageChanged(language: "lv")
    }
    actionSheet.addAction(saveActionButton)

    let deleteActionButton: UIAlertAction = UIAlertAction(title: "English".localized(), style: .default) { _ in
      self.languageChanged(language: "en")
    }
    actionSheet.addAction(deleteActionButton)
    
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  // MARK: - Additonal methods
  func languageChanged(language: String) {
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
    
    let task = URLSession.shared.dataTask(with: url, completionHandler: {[weak self] data, _, error in
      if let error = error {
        debugPrint("Can't download data \(error) \(language)")
        Answers.logCustomEvent(withName: "CantDownloadData", customAttributes: ["language": language, "error": error])
        self?.showError(withMessage: "Can't download data. Please check your settings and try again.".localized())
      } else {
        guard let data = data else { return }
        
        guard let features = try? JSONDecoder().decode(FeatureCollection.self, from: data).features else { return }
        
        do {
          let realm = try Realm()
          
          try realm.write {
            realm.deleteAll()
          }
          
          let realmObjects = features.map({ feature -> DodiesPoint in
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
            dodiesPoint.img2 = properties.img2
            dodiesPoint.url = properties.url
            
            return dodiesPoint
          })
          
          try realm.write {
            realm.add(realmObjects)
          }
          
          self?.checkLastChangedDate(update: false)
          
          DispatchQueue.main.async {
            self?.removeAllAnnotations()
            self?.loadPoints()
          }
        } catch {
          print("Can't update points in Realm")
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
  func loadPoints(checkForUpdatedData: Bool = false) {
    
    do {
      let realm = try Realm()
      
      let points = realm.objects(DodiesPoint.self).filter("st = 'parbaudits'").filter("name = 'Aklā purva taka'")
      
      let mapAnnotations = points.toArray(type: DodiesPoint.self).map({ item -> DodiesAnnotation in
        let point = DodiesAnnotation(latitude: item.latitude, longitude: item.longitude,
                                     name: item.name, tips: item.tips,
                                     st: item.st, km: item.km,
                                     txt: item.txt, dat: item.dat,
                                     img: item.img, img2: item.img2, url: item.url)
        point.coordinate = CLLocationCoordinate2DMake(item.longitude, item.latitude)
        point.title = item.name
        
        return point
      })
      
      mapView.addAnnotations(mapAnnotations)

      DispatchQueue.main.async {
        SwiftSpinner.hide()
        
        if checkForUpdatedData {
          self.checkLastChangedDate(update: true)
        }
      }
    } catch {
      print("Can't load points")
    }
    
  }
  
  // check if need to update
  func checkLastChangedDate(update: Bool) {
    guard let url = URL(string: "http://dodies.lv/apraksti/lastchanged.txt") else { return }
    
    let task = URLSession.shared.dataTask(with: url, completionHandler: {[weak self] data, _, error in
      if let error = error {
        debugPrint("Can't get last changed date \(error)")
      }
      
      guard let data = data else { return }
      
      guard let lastChangedDate = String(data: data, encoding: .utf8) else { return }
      
      guard let timestamp = Int(lastChangedDate.replacingOccurrences(of: "\n", with: "")) else { return }
      
      if update, timestamp > UserDefaults.standard.integer(forKey: Constants.lastChangedTimestampKey.rawValue) {
        self?.downloadData()
      } else {
        UserDefaults.standard.set(timestamp, forKey: Constants.lastChangedTimestampKey.rawValue)
      }
    })
    
    task.resume()
  }
}
