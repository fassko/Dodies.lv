//
//  Coordinator.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import UIKit

protocol Coordinator {
  var childCoordinators: [Coordinator] { get set }
//  var navigationController: UINavigationController { get set }
  
  func start()
}
