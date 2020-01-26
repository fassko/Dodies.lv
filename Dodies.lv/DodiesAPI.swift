//
//  DodiesAPI.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 26/01/2020.
//  Copyright © 2020 fassko. All rights reserved.
//

import Foundation

protocol DodiesAPIProtocol {
  func downloadData(language: String,
                    with featureType: FeatureType,
                    session: URLSession,
                    _ completion: @escaping (Result<[DodiesPoint], DodiesAPIError>) -> Void)
  
  func getLastChangedDate(session: URLSession,
                          _ completion: @escaping (Result<Int, Error>) -> Void)
  
  func getPointDetails(_ url: String,
                       session: URLSession,
                       _ completion: @escaping (Result<DodiesPointDetails, Error>) -> Void)
}

extension DodiesAPIProtocol {
  func downloadData(language: String,
                    with featureType: FeatureType,
                    session: URLSession = URLSession.shared,
                    _ completion: @escaping (Result<[DodiesPoint], DodiesAPIError>) -> Void) {
    downloadData(language: language, with: featureType, session: session, completion)
  }
  
  func getLastChangedDate(session: URLSession = URLSession.shared,
                          _ completion: @escaping (Result<Int, Error>) -> Void) {
    getLastChangedDate(session: session, completion)
  }
  
  func getPointDetails(_ url: String,
                       session: URLSession = URLSession.shared,
                       _ completion: @escaping (Result<DodiesPointDetails, Error>) -> Void) {
    getPointDetails(url, session: session, completion)
  }
}

enum DodiesAPIError: Error {
  case failedWithError(Error)
  case failedDecodeData(Error)
  case noData
}

struct DodiesAPI: DodiesAPIProtocol {
  
  private let address = "https://dodies.lv/"
  
  func downloadData(language: String,
                    with featureType: FeatureType,
                    session: URLSession = URLSession.shared,
                    _ completion: @escaping (Result<[DodiesPoint], DodiesAPIError>) -> Void) {
    let url = URL(string: "\(address)/json/\(language)\(featureType.rawValue).geojson")!
    
    session.dataTask(with: url) { data, _, error in
      if let error = error {
        print("Can't download data \(error) \(String(describing: language))")
        completion(.failure(.failedWithError(error)))
      }
      
      guard let data = data else {
        print("Can't get data")
        completion(.failure(.noData))
        return
      }
      
      do {
        let features = try JSONDecoder().decode(FeatureCollection.self, from: data).features
        
        let points = features.map { feature -> DodiesPoint in
          let dodiesPoint = DodiesPoint()
          dodiesPoint.latitude = feature.geometry.coordinates[1]
          dodiesPoint.longitude = feature.geometry.coordinates[0]
          
          let properties = feature.properties
          dodiesPoint.name = properties.na.removingHTMLEntities
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
        
        completion(.success(points))
      } catch {
        print(error)
        completion(.failure(.failedDecodeData(error)))
      }
    }.resume()
  }
  
  func getLastChangedDate(session: URLSession,
                          _ completion: @escaping (Result<Int, Error>) -> Void) {
    let url = URL(string: "\(address)/apraksti/lastchanged.txt")!
    session.dataTask(with: url) { data, _, error in
      if let error = error {
        debugPrint("Can't get last changed date \(error)")
        completion(.failure(error))
      } else if let data = data,
        let lastChangedDate = String(data: data, encoding: .utf8),
        let timestamp = Int(lastChangedDate.replacingOccurrences(of: "\n", with: "")) {
        completion(.success(timestamp))
      }
    }.resume()
  }
  
  func getPointDetails(_ url: String,
                       session: URLSession,
                       _ completion: @escaping (Result<DodiesPointDetails, Error>) -> Void) {
    let url = URL(string: "\(address)\(url)?json=1")!
    session.dataTask(with: url) { data, _, error in
      if let error = error {
        debugPrint(error)
        completion(.failure(error))
      } else if let data = data {
        do {
          let details = try JSONDecoder().decode(DodiesPointDetails.self, from: data)
          DispatchQueue.main.async {
            completion(.success(details))
          }
        } catch let error {
          print(error)
          completion(.failure(error))
        }
      }
    }.resume()
  }
}
