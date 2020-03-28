//
//  TowerAnnotationView.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/03/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

class TowerAnnotationView: DodiesAnnotationView {
  static let ReuseID = PointType.tower.rawValue
  
  init(annotation: DodiesAnnotation, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    clusteringIdentifier = PointType.tower.rawValue
    
    setImage(placeholder: "binoculars")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    displayPriority = .defaultLow
    markerTintColor = Constants.towerColor
    glyphImage = Constants.towerImage
  }
}
