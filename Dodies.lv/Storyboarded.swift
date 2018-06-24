//
//  Storyboarded.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import UIKit

protocol Storyboarded {
  static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
  static func instantiate() -> Self {
    
    let fullName = NSStringFromClass(self)
    
    let className = fullName.components(separatedBy: ".")[1]
    
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    //swiftlint:disable force_cast
    return storyboard.instantiateViewController(withIdentifier: className) as! Self
  }
}
