//
//  ClusterAnnotationView.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 01/12/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation
import MapKit

class ClusterAnnotationView: MKMarkerAnnotationView {
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    displayPriority = .defaultHigh
    canShowCallout = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var annotation: MKAnnotation? {
    willSet {
      if let cluster = newValue as? MKClusterAnnotation {
        
        markerTintColor = {
          if let firstAnnotation = cluster.memberAnnotations.first as? DodiesAnnotation {
            return firstAnnotation.color
          }
          return #colorLiteral(red: 0.4274509804, green: 0.5921568627, blue: 0.2549019608, alpha: 1)
        }()
        
        glyphText = "\(cluster.memberAnnotations.count)"
      
      }
    }
  }
}
