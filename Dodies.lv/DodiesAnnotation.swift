//
//  Path.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import CoreLocation
import SwiftyJSON

class DodiesAnnotation:MGLPointAnnotation {
  
  var desc:String = ""
  var name:String = ""
  var statuss:String = ""
  var latitude:String = ""
  var longitude:String = ""
  var id:String = ""
  var apraksts:String = ""
  var garums:String = ""
  var datums:String = ""
  var tips:String = ""
}