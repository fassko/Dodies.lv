//
//  Feature.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 30/01/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import Foundation

import RealmSwift

/// Realm interpretation
class DodiesPoint: Object {

  @objc dynamic var latitude: Double = 0
  @objc dynamic var longitude: Double = 0
  
  @objc dynamic var name: String = ""
  @objc dynamic var tips: String = ""
  @objc dynamic var st: String = ""
  @objc dynamic var km: String = ""
  @objc dynamic var txt: String = ""
  @objc dynamic var dat: String = ""
  @objc dynamic var img: String = ""
  @objc dynamic var img2: String = ""
  @objc dynamic var url: String = ""
}
