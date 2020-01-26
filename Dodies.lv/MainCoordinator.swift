//
//  MainCoordinator.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
  var childCoordinators = [Coordinator]()
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let mapViewController = MapViewController.instantiate()
    mapViewController.coordinator = self
    mapViewController.dodiesAPI = DodiesAPI()
    navigationController.pushViewController(mapViewController, animated: false)
  }
  
  func showSettings() {
    let settingsViewController = SettingsViewController.instantiate()
    settingsViewController.coordinator = self
    navigationController.pushViewController(settingsViewController, animated: true)
  }
  
  func showDetails(point: DodiesAnnotation, details: DodiesPointDetails) {
    let detailsViewController = DetailsViewController.instantiate()
    detailsViewController.point = point
    detailsViewController.dodiesPointDetails = details
    navigationController.pushViewController(detailsViewController, animated: true)
  }
  
  func reloadApp() {
    self.start()
  }
}
