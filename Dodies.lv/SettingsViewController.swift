//
//  AboutViewController.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 28/02/16.
//  Copyright © 2016 fassko. All rights reserved.
//

import UIKit

import Localize_Swift

class SettingsViewController: UIViewController, Storyboarded {
  
  @IBOutlet var aboutText: UITextView!
  
  @IBOutlet weak var changeLanguageButton: DodiesButton!
  
  weak var coordinator: MainCoordinator?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.titleView = UIImageView(image: UIImage(named: "dodies_nav_logo"))
    changeLanguageButton.setTitle("Change Language".localized())
    //swiftlint:disable line_length
    aboutText.text = "Dodies.lv is a collection of free nature trails, hiking paths, birdwatching towers and picnic places in Latvia. \nWould you like to spend some time in Latvian nature, make a fire, stay in a tent? Our map contains freely accessible places closer to nature, available at any time for anyone.\n\nThe green icons represent places which we have verified ourselves, they have photos and longer descriptions.\nThe grey icons show places we have not yet given our approval.\n\nHiking in Latvia is now made simple, select a point of interest and use Google Maps, Waze or Apple Maps to navigate there.".localized()

    automaticallyAdjustsScrollViewInsets = false
  }
  
  @IBAction func setLanguage(_ sender: Any) {
    let actionSheet = UIAlertController(title: "Change language".localized(),
                                        message: "Please select language".localized(),
                                        preferredStyle: .actionSheet)
    
    actionSheet.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
    
    let cancelActionButton = UIAlertAction(title: "Cancel".localized(), style: .cancel)
    actionSheet.addAction(cancelActionButton)
    
    let saveActionButton: UIAlertAction = UIAlertAction(title: "Latvian".localized(), style: .default) {[weak self] _ in
      self?.languageChanged(language: "lv")
    }
    actionSheet.addAction(saveActionButton)
    
    let deleteActionButton: UIAlertAction = UIAlertAction(title: "English".localized(), style: .default) {[weak self] _ in
      self?.languageChanged(language: "en")
    }
    actionSheet.addAction(deleteActionButton)
    
    present(actionSheet, animated: true, completion: nil)

  }
  
  // MARK: - Additonal methods
  private func languageChanged(language: String) {
    UserDefaults.standard.set(language, forKey: Constants.languageKey)
    
    Localize.setCurrentLanguage(language)
    coordinator?.reloadApp()
  }
}
