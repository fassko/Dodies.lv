//
//  MapViewController+Data.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 23/02/2019.
//  Copyright © 2019 fassko. All rights reserved.
//

import Foundation
import UIKit

import PromiseKit
import HTMLString

extension MapViewController {
  
  func deleteData() -> Promise<Void> {
    Promise<Void> { seal in
      DispatchQueue.main.async { [weak self] in
        if let error = self?.dataProvider.delete() {
          seal.reject(error)
        } else {
          seal.fulfill(())
        }
      }
    }
  }
  
  func downloadData(with type: FeatureType) -> Promise<Void> {
    Promise { seal in
      dodiesAPI?.downloadData(language: language, with: type) { result in
        switch result {
        case .success(let points):
          DispatchQueue.main.async { [weak self] in
            self?.dataProvider.save(points)
            seal.fulfill(())
          }
        case .failure(let error):
          print(error)
          seal.reject(error)
        }
      }
    }
  }
  
  /// Check if need to update
  ///
  /// - Parameter update: If need to force update
  func checkLastChangedDate(update: Bool) {
    dodiesAPI?.getLastChangedDate {[weak self] result in
      switch result {
      case .success(let timestamp):
        if update, timestamp > UserDefaults.standard.integer(forKey: Constants.lastChangedTimestampKey) {
          self?.downloadData()
        } else {
          UserDefaults.standard.set(timestamp, forKey: Constants.lastChangedTimestampKey)
        }
      case .failure(let error):
        debugPrint("Failed to get last changed date \(error)")
      }
    }
  }
}
