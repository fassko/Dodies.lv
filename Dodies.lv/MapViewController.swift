//
//  Map.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

import MapKit
import Localize_Swift
import SwiftSpinner
import PromiseKit

class MapViewController: UIViewController, CLLocationManagerDelegate, Storyboarded {
  
  weak var coordinator: MainCoordinator?
  
  @IBOutlet private weak var mapView: MKMapView!
  
  private var selectedPoint: DodiesAnnotation!
  private var pointDetails: DodiesPointDetails!
  
  lazy var language: String = {
    guard let language = UserDefaults.standard.string(forKey: Constants.languageKey) else {
      return "lv"
    }
    
    return language
  }()
  
  lazy var lastCheckedDate: String? = {
    guard let lastCheckedDate = UserDefaults.standard.string(forKey: Constants.lastChangedTimestampKey) else {
      return nil
    }
    
    return lastCheckedDate
    
  }()
  
  private let locationManager = CLLocationManager()
  
  internal var dodiesAPI: DodiesAPIProtocol?
  
  internal let dataProvider = DataProvider()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMap()
    
    Localize.setCurrentLanguage(language)
    
    navigationItem.title = "Map".localized()
    navigationItem.titleView = UIImageView(image: UIImage(named: "dodies_nav_logo"))
    
    navigationItem.rightBarButtonItem?.title = "Settings".localized()
    
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    
    SwiftSpinner.setTitleFont(UIFont(name: "HelveticaNeue", size: 18)!)
    SwiftSpinner.show("Downloading data".localized())
    
    if dataProvider.isEmpty {
      downloadData()
    } else {
      loadPoints(checkForUpdatedData: true)
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
    let mapAnnotations = dataProvider.loadPoints().map { point in
      DodiesAnnotation(latitude: point.latitude,
                       longitude: point.longitude,
                       name: point.name,
                       type: point.type,
                       st: point.status,
                       km: point.km,
                       checkedDate: point.checkedDate,
                       url: point.url,
                       img: point.img)
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.removeAllAnnotations()
      self?.mapView.addAnnotations(mapAnnotations)
      SwiftSpinner.hide()
      
      if checkForUpdatedData {
        self?.checkLastChangedDate(update: true)
      }
    }
  }
}
