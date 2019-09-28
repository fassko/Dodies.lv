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
import PromiseKit

class MapViewController: UIViewController, CLLocationManagerDelegate, Storyboarded {
  
  weak var coordinator: MainCoordinator?

  var selectedPoint: DodiesAnnotation!
  
  var pointDetails: DodiesPointDetails!
  
  @IBOutlet private weak var mapView: MKMapView!
  
  var language: String = {
    guard let language = UserDefaults.standard.string(forKey: Constants.languageKey) else {
      return "lv"
    }
    
    return language
  }()
  
  private let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMap()
    
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
  
  private func setupMap() {
    
    let centerCoordinate = CLLocationCoordinate2D(latitude: 56.8800000, longitude: 24.6061111)
    let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 200000, longitudinalMeters: 500000)
    
    mapView.setRegion(region, animated: false)
    
    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.isRotateEnabled = true
    
    mapView.showsScale = true
    
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
  func downloadData() {
    firstly {
      deleteData()
    }.then { _ in
      self.downloadData(with: .taka)
    }.then {_ in
      self.downloadData(with: .tornis)
    }
    .then { _ in
      self.downloadData(with: .pikniks)
    }.done { _ in
      self.checkLastChangedDate(update: false)
      
      DispatchQueue.main.async {
        self.removeAllAnnotations()
        self.loadPoints()
      }
    }.catch {
      debugPrint("Can't download data \($0)")
    }
  }
  
  /// Remove all annotation from mapview
  private func removeAllAnnotations() {
    let annotations = mapView.annotations
    
    guard annotations.isEmpty else { return }
    
    mapView.removeAnnotations(annotations)
  }
  
  private func loadPoints(checkForUpdatedData: Bool = false) {
    
    do {
      let realm = try Realm()
   
      let points: Results<DodiesPoint> = {
        if CommandLine.arguments.contains("-local") {
          return realm.objects(DodiesPoint.self)
            .filter("txt != ''")
//            .filter("st = 'parbaudits'")
//            .filter("name BEGINSWITH 'Atpūtas vieta'")
            .filter("name BEGINSWITH 'Viesatas upesloku takas'")
        } else {
          return realm.objects(DodiesPoint.self)
            .filter("txt != ''")
        }
      }()
      
      let mapAnnotations = points.toArray(type: DodiesPoint.self).map { item in
        DodiesAnnotation(latitude: item.latitude,
                         longitude: item.longitude,
                         name: item.name.removingHTMLEntities,
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
}
