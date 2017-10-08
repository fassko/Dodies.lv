//
//  Feature.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 30/01/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import Foundation

import RealmSwift

// MARK: - Codable

/// Feature collection
struct FeatureCollection: Codable {
  /// Type
  var type: String
  
  /// Array of features
  var features: [Feature]
}

/// Feature object
struct Feature: Codable {
  /// Type
  var type: String
  
  /// Feture properties
  var properties: Property
  
  /// Geometry
  var geometry: Geometry
}

/// Feature properties
struct Property: Codable {

  /// Name
  var name: String
  
  /// Type
  var tips: String
  
  /// Status
  var st: String
  
  /// Lenght in km
  var km: String
  
  /// Description
  var txt: String
  
  /// Date when checked
  var dat: String
  
  /// Picture
  var img: String
  
  /// Url of description
  var url: String
}

/// Feature geometry (coordinates)
struct Geometry: Codable {
  /// Type
  var type: String
  
  /// Coordinates array (0: longitude, 1: latitude)
  var coordinates: [Double]
}

// MARK: - Realm
class DodiesPoint: Object {

  @objc dynamic var latitude:Double = 0
  @objc dynamic var longitude:Double = 0
  
  @objc dynamic var name:String = ""
  @objc dynamic var tips:String = ""
  @objc dynamic var st:String = ""
  @objc dynamic var km:String = ""
  @objc dynamic var txt:String = ""
  @objc dynamic var dat:String = ""
  @objc dynamic var img:String = ""
  @objc dynamic var url:String = ""
}
