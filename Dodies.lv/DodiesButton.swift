//
//  DodiesButton.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 8/17/18.
//  Copyright © 2018 fassko. All rights reserved.
//

import UIKit

@IBDesignable class DodiesButton: UIButton {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    sharedInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    sharedInit()
  }
  
  override func prepareForInterfaceBuilder() {
    sharedInit()
  }
  
  private func sharedInit() {
    backgroundColor = Constants.greenColor
    tintColor = .white
    titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18)
  }

}
