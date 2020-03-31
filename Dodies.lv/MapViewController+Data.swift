//
//  MapViewController+Data.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 23/02/2019.
//  Copyright © 2019 fassko. All rights reserved.
//

import Foundation

import PromiseKit
import RealmSwift
import HTMLString

extension MapViewController {
  
  func deleteData() -> Promise<Void> {
    Promise<Void> { seal in
      do {
        let realm = try Realm()
        
        try realm.write {
          realm.deleteAll()
          seal.fulfill(())
        }
      } catch {
        seal.reject(error)
        fatalError("Can't update points in Realm")
      }
    }
  }
  
  func downloadData(with type: FeatureType) -> Promise<Void> {
    Promise { seal in
      dodiesAPI?.downloadData(language: language, with: type) { result in
        switch result {
        case .success(let points):
          do {
            let realm = try Realm()
            try realm.write {
              realm.add(points)
              seal.fulfill(())
            }
          } catch {
            seal.reject(error)
            fatalError("Can't update points in Realm")
          }
        case .failure(let error):
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
