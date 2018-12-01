//
//  ClusterAnnotationView.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 01/12/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation
import MapKit

class ClusterAnnotationView: MKAnnotationView {
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    collisionMode = .circle
    centerOffset = CGPoint(x: 0, y: -10)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    
    if let cluster = annotation as? MKClusterAnnotation {
      let total = cluster.memberAnnotations.count
      
      let color: UIColor = {
        if let firstAnnotation = cluster.memberAnnotations.first as? DodiesAnnotation {
          return firstAnnotation.color
        }
        return #colorLiteral(red: 0.4274509804, green: 0.5921568627, blue: 0.2549019608, alpha: 1)
      }()
      
      image = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        
        return renderer.image { _ in
          color.setFill()
          UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
          
          UIColor.white.setFill()
          UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 24, height: 24)).fill()
          
          let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)
          ]
          let text = "\(total)"
          let size = text.size(withAttributes: attributes)
          let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
          text.draw(in: rect, withAttributes: attributes)
        }
      }()
    }
  }
}
