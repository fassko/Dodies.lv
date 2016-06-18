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
import LKAlertController
import Alamofire
import AlamofireImage
import SwiftDate

class Details : UIViewController {

  var point : DodiesAnnotation!
  
  @IBOutlet weak var desc: UITextView!
  @IBOutlet weak var coordinatesButton: UIButton!
  @IBOutlet weak var lenght: UILabel!
  @IBOutlet weak var checked: UILabel!
  @IBOutlet weak var details: UIBarButtonItem!
  
  @IBOutlet weak var image: UIImageView?
  
  
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
    
    desc.scrollEnabled = false
    desc.text = point.txt
    

    self.automaticallyAdjustsScrollViewInsets = false
    
    coordinatesButton.setTitle("\(String(format: "%.5f",point.coordinate.latitude)), \(String(format: "%.5f",point.coordinate.longitude))", forState: UIControlState.Normal)
    
    lenght.text = point.km != "" ? "\(point.km) km" : "-"
    
    if point.dat != "" {
      let checkedDate = point.dat.toDate(DateFormat.Custom("yyyy-MM-dd HH:mm:ss"))
      
      checked.text = checkedDate!.toString(DateFormat.Custom("MM.dd.YYYY"))
    } else {
      checked.text = "-"
    }
    
    let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
    details.setTitleTextAttributes(attributes, forState: .Normal)
    details.title = String.fontAwesomeIconWithName(.Info)
    
    Alamofire.request(.GET, point.img).responseImage {
      response in

        if let image = response.result.value {
          let radius: CGFloat = 10.0

          self.image?.image = image.af_imageWithRoundedCornerRadius(radius)
        }
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
                      contentId: point.name,
                      customAttributes: ["name": point.name, "description": point.description])
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    desc.scrollEnabled = true
  }
  
  @IBAction func showDescription(sender: AnyObject) {
    if !point.url.isEmpty {
      performSegueWithIdentifier("showDescription", sender: self)
    } else {
      Alert(title: "Dodies.lv", message: "Diemžēl apraksts vēl nav izveidots.").addAction("OK").show()
    }
  }
  
  @IBAction func openNavigation(sender: AnyObject) {
    let optionMenu = UIAlertController(title: nil, message: "Navigēt ar", preferredStyle: .ActionSheet)

    let apple = UIAlertAction(title: "Apple Maps", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
        let u = "http://maps.apple.com/?daddr=\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)"
        UIApplication.sharedApplication().openURL(NSURL(string: u)!)
    })
    
    let google = UIAlertAction(title: "Google Maps", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in
      
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
          UIApplication.sharedApplication().openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)&directionsmode=driving")!)

        } else {
          let link = "http://itunes.apple.com/us/app/id585027354"
          UIApplication.sharedApplication().openURL(NSURL(string: link)!)
          UIApplication.sharedApplication().idleTimerDisabled = true
        }
    })
    
    let waze = UIAlertAction(title: "Waze", style: .Default, handler: {
      (alert: UIAlertAction!) -> Void in

        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "waze://")!) {
            UIApplication.sharedApplication().openURL(NSURL(string: "waze://?ll=\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)&navigate=yes")!)
            UIApplication.sharedApplication().idleTimerDisabled = true
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://itunes.apple.com/us/app/id323229106")!)
            UIApplication.sharedApplication().idleTimerDisabled = true
        }
    })

    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
      (alert: UIAlertAction!) -> Void in
    })
    
    optionMenu.addAction(apple)
    optionMenu.addAction(google)
    optionMenu.addAction(waze)
    optionMenu.addAction(cancelAction)
    
    self.presentViewController(optionMenu, animated: true, completion: nil)
  }
  
  // pass object to details view
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDescription" {
    
      if let description: DescriptionViewController = segue.destinationViewController as? DescriptionViewController {
        navigationItem.title = ""
        description.point = self.point
      }
    }
  }
  
}