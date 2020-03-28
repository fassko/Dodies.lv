//
//  MainCoordinator.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
  private let window: UIWindow?
  var childCoordinators = [Coordinator]()
  
  var navigationController: UINavigationController?
  
  init(window: UIWindow?) {
    self.window = window
  }
  
  func start() {
    let mapViewController = MapViewController.instantiate()
    mapViewController.coordinator = self
    mapViewController.dodiesAPI = DodiesAPI()
    
    navigationController = UINavigationController(rootViewController: mapViewController)
    navigationController?.navigationBar.barTintColor = Constants.greenColor
    navigationController?.navigationBar.tintColor = .white
    navigationController?.navigationBar.isTranslucent = true
    
    window?.rootViewController = navigationController
  }
  
  func showSettings() {
    let settingsViewController = SettingsViewController.instantiate()
    settingsViewController.coordinator = self
    navigationController?.pushViewController(settingsViewController, animated: true)
  }
  
  func showDetails(point: DodiesAnnotation, details: DodiesPointDetails) {
    let detailsViewController = DetailsViewController.instantiate()
    detailsViewController.point = point
    detailsViewController.dodiesPointDetails = details
    navigationController?.pushViewController(detailsViewController, animated: true)
  }
  
  func reloadApp() {
    self.start()
  }
}
