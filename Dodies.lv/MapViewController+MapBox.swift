//
//  MapViewController+MapBox.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 25/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation
import Mapbox

// MARK: - Mapbox implementation
extension MapViewController {
  
  func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
    do {
      guard let selectedPoint = annotation as? DodiesAnnotation else { return nil }
      
      var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: selectedPoint.icon)
      
      if annotationImage == nil, let image = UIImage(named: selectedPoint.icon) {
        annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: selectedPoint.icon)
      }
      
      return annotationImage
    }
  }
  
  func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
    return UIButton.init(type: UIButton.ButtonType.infoLight)
  }
  
  func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
    if let point = annotation as? DodiesAnnotation {
      selectedPoint = point
      
      DetailsProvider.getFor(point.url) {[weak self] details in
        guard let pointDetails = details else { return }
        
        self?.pointDetails = pointDetails
        
        DispatchQueue.main.async {
          guard let point = self?.selectedPoint else { return }
          
          self?.coordinator?.showDetails(point: point, details: pointDetails)
          self?.selectedPoint = nil
        }
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
}
