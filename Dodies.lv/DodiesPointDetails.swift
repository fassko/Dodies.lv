//
//  DodiesPointDetails.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/04/2018.
//  Copyright © 2018 fassko. All rights reserved.
//

import Foundation

/// Dodies point details
struct DodiesPointDetails: Codable {
  
  /// Image
  let image: String?
  
  /// Title
  let title: String
  
  /// Description
  let description: String
  
  /// Array of images
  let images: [String]?
  
  enum CodingKeys: String, CodingKey {
    case image
    case title
    case description = "desc-short"
    case images
  }
}
