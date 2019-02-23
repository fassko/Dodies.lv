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

extension MapViewController {
  
  func deleteData() -> Promise<Void> {
    return Promise<Void> { seal in
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
    return Promise { seal in
      
      let url = URL(string: "https://dodies.lv/json/\(language)\(type.rawValue).geojson")!
      
      let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
        if let error = error {
          debugPrint("Can't download data \(error) \(String(describing: self?.language))")
          self?.showError(withMessage: "Can't download data. Please check your settings and try again.".localized())
          seal.reject(error)
        } else {
          
          guard let data = data,
            let features = try? JSONDecoder().decode(FeatureCollection.self, from: data).features else {
              return
          }
          
          do {
            let realm = try Realm()
            
            let realmObjects = features.map { feature -> DodiesPoint in
              let dodiesPoint = DodiesPoint()
              dodiesPoint.latitude = feature.geometry.coordinates[1]
              dodiesPoint.longitude = feature.geometry.coordinates[0]
              
              let properties = feature.properties
              dodiesPoint.name = properties.na
              dodiesPoint.tips = properties.ti.rawValue
              dodiesPoint.st = properties.st
              dodiesPoint.km = properties.km
              dodiesPoint.txt = properties.txt
              dodiesPoint.dat = properties.dat
              dodiesPoint.img = properties.img
              dodiesPoint.img2 = properties.img2
              dodiesPoint.url = properties.url
              
              return dodiesPoint
            }
            
            try realm.write {
              realm.add(realmObjects)
              seal.fulfill(())
            }
          } catch {
            seal.reject(error)
            fatalError("Can't update points in Realm")
          }
        }
      }
      
      task.resume()
    }
  }
  
  /// Check if need to update
  ///
  /// - Parameter update: If need to force update
  func checkLastChangedDate(update: Bool) {
    let url = URL(string: "https://dodies.lv/apraksti/lastchanged.txt")!
    
    URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
      if let error = error {
        debugPrint("Can't get last changed date \(error)")
      } else if let data = data,
        let lastChangedDate = String(data: data, encoding: .utf8),
        let timestamp = Int(lastChangedDate.replacingOccurrences(of: "\n", with: "")) {
        
        if update, timestamp > UserDefaults.standard.integer(forKey: Constants.lastChangedTimestampKey) {
          self?.downloadData()
        } else {
          UserDefaults.standard.set(timestamp, forKey: Constants.lastChangedTimestampKey)
        }
      }
    }.resume()
  }
}
