//
//  Details.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import UIKit
import Attributed

class Details : UIViewController {

  var point : DodiesAnnotation!
  
  @IBOutlet weak var pointTitle: UILabel!
  @IBOutlet weak var desc: UITextView!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var descriptionLinkButton: UIButton!
  @IBOutlet weak var coordinatesButton: UIButton!
  @IBOutlet weak var lenghtLabel: UILabel!
  @IBOutlet weak var lenght: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var price: UILabel!
  @IBOutlet weak var checkedLabel: UILabel!
  @IBOutlet weak var checked: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pointTitle.text = point.title
    
    desc.text = point.desc
    
    
    closeButton.layer.cornerRadius = 5
    descriptionLinkButton.layer.cornerRadius = 5
    coordinatesButton.titleLabel?.text = "   \(point.coordinate.latitude),\(point.coordinate.longitude)"
    
    if point.garums != "" {
      lenght.text = "\(point.garums) km"
      lenght.hidden = false
      lenghtLabel.hidden = false
    }
    
    
    
    if (point.datums != "") {
      checkedLabel.hidden = false
      checked.hidden = false
      checked.text = point.datums
    }
    
    if point.samaksa == "maksas" {
      priceLabel.hidden = false
      price.hidden = false
    }
    
    if point.apraksts == "true" {
      descriptionLinkButton.hidden = false
    }
    
  }
  
  @IBAction func done(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func showDescription(sender: AnyObject) {
    UIApplication.sharedApplication().openURL(NSURL(string: "http://dodies.lv/info?taka=\(point.id)")!)
  }
  
  @IBAction func openNavigation(sender: AnyObject) {
    let u = "http://maps.apple.com/?daddr=\(point.coordinate.latitude),\(point.coordinate.longitude)"
    print(u)
    UIApplication.sharedApplication().openURL(NSURL(string: u)!)

  }
  
}