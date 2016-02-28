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
import Fabric
import Crashlytics

class Details : UIViewController {

  var point : DodiesAnnotation!
  
  @IBOutlet weak var desc: UITextView!
  @IBOutlet weak var descriptionLinkButton: UIButton!
  @IBOutlet weak var coordinatesButton: UIButton!
  @IBOutlet weak var lenght: UILabel!
  @IBOutlet weak var checked: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = point.title
    
    let titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.size.width - 120, 44))
    titleLabel.backgroundColor = UIColor.clearColor()
    titleLabel.font = UIFont(name: "HelveticaNeue-Medium",  size: 18)
    titleLabel.textAlignment = NSTextAlignment.Center
    titleLabel.text = self.title
    titleLabel.textColor = UIColor.whiteColor()
    titleLabel.adjustsFontSizeToFitWidth = true
    
    self.navigationItem.titleView = titleLabel
    
    desc.text = point.desc
    self.automaticallyAdjustsScrollViewInsets = false
    
    descriptionLinkButton.layer.cornerRadius = 5
    coordinatesButton.titleLabel?.text = "\(point.coordinate.latitude),\(point.coordinate.longitude)"
    
    lenght.text = point.garums != "" ? "\(point.garums) km" : "-"
    checked.text = point.datums != "" ? point.datums : "-"
    
    if point.apraksts == "true" {
      descriptionLinkButton.hidden = false
    }
    
  }
  
  override func viewWillAppear(animated: Bool) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Details")
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
    
    let eventTracker: NSObject = GAIDictionaryBuilder.createEventWithCategory(
                    "Details",
                    action: "DodiesDetails",
                    label: point.name,
                    value: nil).build()
    tracker.send(eventTracker as! [NSObject : AnyObject])
    
    Answers.logContentViewWithName("Details",
                      contentType: "DodiesDetails",
                      contentId: point.id,
                      customAttributes: ["name": point.name, "description": point.description])    
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