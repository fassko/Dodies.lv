//
//  MapViewController+MapKit.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 25/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

import MapKit

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? DodiesAnnotation else {
      return nil
    }
    
    switch annotation.type {
    case .trail:
      return TrailAnnotationView(annotation: annotation, reuseIdentifier: TrailAnnotationView.ReuseID)
    case .tower:
      return TowerAnnotationView(annotation: annotation, reuseIdentifier: TowerAnnotationView.ReuseID)
    case .picnic:
      return PicnicAnnotationView(annotation: annotation, reuseIdentifier: PicnicAnnotationView.ReuseID)
    }
  }
  
  func mapView(_ mapView: MKMapView,
               annotationView view: MKAnnotationView,
               calloutAccessoryControlTapped control: UIControl) {
    
    guard let annotation = view.annotation as? DodiesAnnotation else {
      return
    }
    
    dodiesAPI?.getPointDetails(annotation.url) {[weak self] result in
      switch result {
      case .success(let details):
        self?.coordinator?.showDetails(point: annotation, details: details)
      case .failure(let error):
        print(error)
      }
    }
    
    mapView.deselectAnnotation(annotation, animated: true)
  }
}
