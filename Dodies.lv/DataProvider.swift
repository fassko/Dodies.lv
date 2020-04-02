//
//  DataProvider.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 02/04/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import CoreData
import Foundation
import UIKit

struct DataProvider {
  var appDelegate: AppDelegate? {
    return UIApplication.shared.delegate as? AppDelegate
  }
  
  var isEmpty: Bool {
    loadPoints().isEmpty
  }
  
  func loadPoints() -> [Point] {
    guard let appDelegate = appDelegate else {
      return []
    }
    
    do {
      let managedContext = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DodiesPoint")
      
      if CommandLine.arguments.contains("-local") {
        fetchRequest.predicate = NSPredicate(format: "name = %@", "Viesatas upesloku taka")
      }
      
      let fetchedPoints = try managedContext.fetch(fetchRequest)
      
      let points = fetchedPoints.compactMap { fetchedPoint -> Point? in
        guard let latitude = fetchedPoint.value(forKey: "latitude") as? Double,
          let longitude = fetchedPoint.value(forKey: "longitude") as? Double,
          let name = fetchedPoint.value(forKey: "name") as? String,
          let type = fetchedPoint.value(forKey: "type") as? String,
          let status = fetchedPoint.value(forKey: "status") as? String,
          let url = fetchedPoint.value(forKey: "url") as? String,
          let img = fetchedPoint.value(forKey: "img") as? String,
          let km = fetchedPoint.value(forKey: "km") as? String,
          let checkedDate = fetchedPoint.value(forKey: "checkedDate") as? String
          else {
            return nil
        }
        
        return Point(name: name,
                     latitude: latitude,
                     longitude: longitude,
                     status: status,
                     type: type,
                     url: url,
                     img: img,
                     km: km,
                     checkedDate: checkedDate)
      }
      
      return points
    } catch {
      debugPrint(error)
      return []
    }
  }
  
  func save(_ points: [Point]) {
    guard let appDelegate = appDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "DodiesPoint", in: managedContext)!
    
    points.forEach { point in
      let dodiesPoint = NSManagedObject(entity: entity, insertInto: managedContext)
      dodiesPoint.setValue(point.name, forKeyPath: "name")
      dodiesPoint.setValue(point.latitude, forKeyPath: "latitude")
      dodiesPoint.setValue(point.longitude, forKeyPath: "longitude")
      dodiesPoint.setValue(point.img, forKeyPath: "img")
      dodiesPoint.setValue(point.status, forKeyPath: "status")
      dodiesPoint.setValue(point.type, forKeyPath: "type")
      dodiesPoint.setValue(point.url, forKeyPath: "url")
      dodiesPoint.setValue(point.checkedDate, forKeyPath: "checkedDate")
      dodiesPoint.setValue(point.km, forKeyPath: "km")

      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
  }
  
  func delete() -> Error? {
    guard let appDelegate = appDelegate else {
      return nil
    }
    
    do {
      let managedContext = appDelegate.persistentContainer.viewContext
      
      let requestVar = NSFetchRequest<NSFetchRequestResult>(entityName: "DodiesPoint")
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: requestVar)
      try managedContext.execute(deleteRequest)
      
      return nil
    } catch {
      debugPrint(error)
      return error
    }
  }
}
