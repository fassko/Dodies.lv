//
//  Extensions.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 08/10/2017.
//  Copyright © 2017 fassko. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {
  /**
    Get value with default value
   
    - Parameters:
      - forKey: Key of User Default
      - default: Default value
  */
  static func getValue(forKey key: String, default defaultValue: String) -> String {
    guard let value = standard.string(forKey: key) else {
      return defaultValue
    }
    
    return value
  }
}

extension UIViewController {
  
  var titleLabel: UILabel {
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
    titleLabel.backgroundColor = UIColor.clear
    titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
    titleLabel.textAlignment = NSTextAlignment.center
    titleLabel.text = title
    titleLabel.textColor = UIColor.white
    titleLabel.adjustsFontSizeToFitWidth = true
    
    return titleLabel
  }
  
  // Show Dodies.lv error
  func showError(withMessage message: String, title: String = "Dodies.lv") {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}

extension UIButton {
  func setTitle(_ title: String) {
    setTitle(title, for: .normal)
    setTitle(title, for: .highlighted)
  }
}
