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

import MapKit
import RealmSwift
import Localize_Swift
import SwiftSpinner

class MapViewController: UIViewController, CLLocationManagerDelegate, Storyboarded {
  
  weak var coordinator: MainCoordinator?

  var selectedPoint: DodiesAnnotation!
  
  var pointDetails: DodiesPointDetails!
  
  @IBOutlet private weak var mapView: MKMapView!
  
  private var language: String = {
    guard let language = UserDefaults.standard.string(forKey: Constants.languageKey) else {
      return "lv"
    }
    
    return language
  }()
  
  private let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMapView()
    
    debugPrint(Realm.Configuration.defaultConfiguration.fileURL!)
    Localize.setCurrentLanguage(language)
    
    navigationItem.title = "Map".localized()
    navigationItem.titleView = UIImageView(image: UIImage(named: "dodies_nav_logo"))
    
    navigationItem.rightBarButtonItem?.title = "Settings".localized()
    
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    
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
      fatalError("Can't load points from Realm")
    }
  }
  
  private func setupMapView() {
    let centerCoordinate = CLLocationCoordinate2D(latitude: 56.8800000, longitude: 24.6061111)
    let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 200000, longitudinalMeters: 500000)
    mapView.setRegion(region, animated: false)
    
    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.isRotateEnabled = true
    
    mapView.register(TrailAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.register(TowerAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    mapView.register(PicnicAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    
    mapView.register(ClusterAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
  }
  
  // MARK: - Interface methods
  @IBAction func settings(sender: AnyObject) {
    coordinator?.showSettings()
  }
  
  // download data from server
  private func downloadData() {
  
    guard let url = URL(string: "http://dodies.lv/json/\(language).geojson") else { return }
    
    let task = URLSession.shared.dataTask(with: url, completionHandler: {[weak self] data, _, error in
      if let error = error {
        debugPrint("Can't download data \(error) \(String(describing: self?.language))")
        self?.showError(withMessage: "Can't download data. Please check your settings and try again.".localized())
      } else {
        guard let data = data,
          let features = try? JSONDecoder().decode(FeatureCollection.self, from: data).features else {
          return
        }

        do {
          let realm = try Realm()
          
          try realm.write {
            realm.deleteAll()
          }
          
          let realmObjects = features.map({ feature -> DodiesPoint in
            let dodiesPoint = DodiesPoint()
            dodiesPoint.latitude = feature.geometry.coordinates[1]
            dodiesPoint.longitude = feature.geometry.coordinates[0]
            
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
          fatalError("Can't update points in Realm")
        }
      }
    })
    
    task.resume()
  }
  
  // remove all annotation from mapview
  private func removeAllAnnotations() {
    let annotations = mapView.annotations
    
    guard annotations.isEmpty else { return }
    
    mapView.removeAnnotations(annotations)
  }
  
  private func loadPoints(checkForUpdatedData: Bool = false) {
    
    do {
      let realm = try Realm()
      
      let points = realm.objects(DodiesPoint.self)
//        .filter("st = 'parbaudits'")
//      .filter("name = 'Aklā purva taka'")
      
      let mapAnnotations = points.toArray(type: DodiesPoint.self).map { item in
        DodiesAnnotation(latitude: item.latitude,
                         longitude: item.longitude,
                         name: item.name,
                         tips: item.tips,
                         st: item.st,
                         km: item.km,
                         dat: item.dat,
                         url: item.url)
      }
      
      DispatchQueue.main.async {
        
        self.mapView.addAnnotations(mapAnnotations)
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
  private func checkLastChangedDate(update: Bool) {
    let url = URL(string: "http://dodies.lv/apraksti/lastchanged.txt")!
    
    URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
      if let error = error {
        debugPrint("Can't get last changed date \(error)")
      }
      
      guard let data = data,
        let lastChangedDate = String(data: data, encoding: .utf8),
        let timestamp = Int(lastChangedDate.replacingOccurrences(of: "\n", with: "")) else {
        return
      }
      
      if update, timestamp > UserDefaults.standard.integer(forKey: Constants.lastChangedTimestampKey) {
        self?.downloadData()
      } else {
        UserDefaults.standard.set(timestamp, forKey: Constants.lastChangedTimestampKey)
      }
    }.resume()
  }
}
