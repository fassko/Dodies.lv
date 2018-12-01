//
//  DetailsProvider.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

enum Result<Value> {
  case success(Value)
  case failure(Error)
}

enum DetailsProvider {
  
  static func getFor(_ url: String, completion: @escaping (Result<DodiesPointDetails>) -> Void) {
    
    let url = URL(string: "https://dodies.lv\(url)?json=1")!

    URLSession.shared.dataTask(with: url) { data, _, error in
      if let error = error {
        debugPrint(error)
        completion(.failure(error))
      } else if let data = data {
        do {
          let details = try JSONDecoder().decode(DodiesPointDetails.self, from: data)
          completion(.success(details))
        } catch let error {
          print(error)
          completion(.failure(error))
        }
      }
    }.resume()
  }
  
}
