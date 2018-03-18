//
//  Extensions.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 08/10/2017.
//  Copyright © 2017 fassko. All rights reserved.
//

import Foundation

import RealmSwift

extension UserDefaults {
  /**
    Get value with default value
   
    - Parameters:
      - forKey: Key of User Default
      - default: Default value
  */
  static func getValue(forKey key: String, default defaultValue: String) -> String {
    guard let value = self.standard.string(forKey: key) else {
      return defaultValue
    }
    
    return value
  }
}

extension Results {
  func toArray<T>(ofType: T.Type) -> [T] {
    var array = [T]()
    for i in 0 ..< count {
      if let result = self[i] as? T {
        array.append(result)
      }
    }
    
    return array
  }
}
