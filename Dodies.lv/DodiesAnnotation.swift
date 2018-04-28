//
//  Path.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation

import Mapbox

class DodiesAnnotation: MGLPointAnnotation {
  var latitude: Double
  var longitude: Double
  var name: String
  var tips: String
  var st: String
  var km: String
  var txt: String
  var dat: String
  var img: String
  var img2: String
  var url: String
  
  init(latitude: Double, longitude: Double,
       name: String, tips: String,
       st: String, km: String,
       txt: String, dat: String,
       img: String, img2: String, url: String) {
    
    self.latitude = latitude
    self.longitude = longitude
    self.name = name
    self.tips = tips
    self.st = st
    self.km = km
    self.txt = txt
    self.dat = dat
    self.img = img
    self.img2 = img2
    self.url = url
    
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension DodiesAnnotation {
  var icon: String {
    if st == "parbaudits" {
      return "\(tips)-active"
    } else {
      return "\(tips)-disabled"
    }
  }
}
