//
//  DodiesAnnotationView.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/03/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation
import MapKit
import UIKit

import Kingfisher

class DodiesAnnotationView: MKMarkerAnnotationView {
  override func prepareForDisplay() {
    super.prepareForDisplay()
    displayPriority = .defaultHigh
    canShowCallout = true
    rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
  }
  
  func setImage(placeholder: String) {
    guard let annotation = annotation as? DodiesAnnotation, let imgURL = URL(string: annotation.img) else {
      return
    }
    
    let annotationImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    annotationImageView.image = UIImage(named: placeholder)
    leftCalloutAccessoryView = annotationImageView
    annotationImageView.kf.indicatorType = .activity
    
    let options: KingfisherOptionsInfo = [
      .scaleFactor(UIScreen.main.scale),
      .transition(.fade(0.5))
    ]
    
    annotationImageView.kf.setImage(
      with: imgURL,
      placeholder: UIImage(named: placeholder),
      options: options)
  }
}
