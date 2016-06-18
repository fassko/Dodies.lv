//
//  Feature.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 30/01/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import Foundation
import RealmSwift

class DodiesPoint: Object {

  dynamic var latitude:Double = 0
  dynamic var longitude:Double = 0
  
  dynamic var name:String = ""
  dynamic var tips:String = ""
  dynamic var st:String = ""
  dynamic var km:String = ""
  dynamic var txt:String = ""
  dynamic var dat:String = ""
  dynamic var img:String = ""
  dynamic var img2:String = ""
  dynamic var url:String = ""
}
