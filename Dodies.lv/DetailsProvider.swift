//
//  DetailsProvider.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

enum DetailsProvider {
  
  static func getFor(_ url: String, completion: @escaping (DodiesPointDetails?) -> Void) {
    
    guard let url = URL(string: "https://dodies.lv\(url)?json=1") else { return }

    URLSession.shared.dataTask(with: url) { data, _, error in
      if let error = error {
        print(error)
        completion(nil)
      } else if let data = data {
        do {
          let details = try JSONDecoder().decode(DodiesPointDetails.self, from: data)
          completion(details)
        } catch let error {
          print(error)
          completion(nil)
        }
      }
    }.resume()
  }
  
}
