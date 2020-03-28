//
//  TrailAnnotationView.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/03/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

class TrailAnnotationView: DodiesAnnotationView {
  static let ReuseID = PointType.trail.rawValue
  
  init(annotation: DodiesAnnotation, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    
    clusteringIdentifier = PointType.trail.rawValue
    
    setImage(placeholder: "signpost")
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    markerTintColor = Constants.trailColor
    glyphImage = Constants.trailImage
  }
}
