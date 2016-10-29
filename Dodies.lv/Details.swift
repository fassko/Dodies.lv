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
import Localize_Swift

class Details : UIViewController {

  var point : DodiesAnnotation!
  
  @IBOutlet weak var desc: UITextView!
  @IBOutlet weak var coordinatesButton: UIButton!
  @IBOutlet weak var lenght: UILabel!
  @IBOutlet weak var checked: UILabel!
  @IBOutlet weak var details: UIBarButtonItem!
  
  @IBOutlet weak var lengthTitle: UILabel!
  @IBOutlet weak var checkedTitle: UILabel!
  
  @IBOutlet weak var image: UIImageView?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = point.name
    
    checkedTitle.text = "Checked".localized()
    lengthTitle.text = "Length".localized()
    
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
    titleLabel.backgroundColor = UIColor.clear
    titleLabel.font = UIFont(name: "HelveticaNeue-Medium",  size: 18)
    titleLabel.textAlignment = NSTextAlignment.center
    titleLabel.text = self.title
    titleLabel.textColor = UIColor.white
    titleLabel.adjustsFontSizeToFitWidth = true
    
    self.navigationItem.titleView = titleLabel
    
    desc.isScrollEnabled = false
    desc.text = point.txt
    

    self.automaticallyAdjustsScrollViewInsets = false
    
    coordinatesButton.setTitle("\(String(format: "%.5f",point.coordinate.latitude)), \(String(format: "%.5f",point.coordinate.longitude))", for: UIControlState.normal)
    
    lenght.text = point.km != "" ? "\(point.km) km" : "-"
    
    if point.dat != "" {
      
      let checkedDate = try! point.dat.date(format: DateFormat.custom("yyyy-MM-dd"))
      
      checked.text = checkedDate.string(format: DateFormat.custom("MM.dd.YYYY"))
    } else {
      checked.text = "-"
    }
    
    let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20)] as Dictionary!
    details.setTitleTextAttributes(attributes, for: .normal)
    details.title = String.fontAwesomeIcon(name: .info)
    
    Alamofire.request(point.img).responseImage {
      response in

        if let image = response.result.value {
          let radius: CGFloat = 10.0

          self.image?.image = image.af_imageRounded(withCornerRadius: radius)
        }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker?.set(kGAIScreenName, value: "Details")
    
    var eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
    tracker?.send(eventTracker as! [NSObject : AnyObject])
    
    eventTracker = GAIDictionaryBuilder.createEvent(
      withCategory: "Details",
                    action: "DodiesDetails",
                    label: point.name,
                    value: nil).build()
    tracker?.send(eventTracker as! [NSObject : AnyObject])
    
    Answers.logContentView(withName: "Details",
                      contentType: "DodiesDetails",
                      contentId: point.name,
                      customAttributes: ["name": point.name, "description": point.description])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    desc.isScrollEnabled = true
  }
  
  @IBAction func showDescription(sender: AnyObject) {
    if !point.url.isEmpty {
      performSegue(withIdentifier: "showDescription", sender: self)
    } else {
      Alert(title: "Dodies.lv", message: "Sorry, but description isn't ready yet.".localized()).addAction("OK").show()
    }
  }
  
  @IBAction func openNavigation(sender: AnyObject) {
    let optionMenu = UIAlertController(title: nil, message: "Navigate with".localized(), preferredStyle: .actionSheet)
    
    let copy = UIAlertAction(title: "Copy coordiantes".localized(), style: .default, handler: {
      (alert: UIAlertAction!) -> Void in
        let pasteboard:UIPasteboard = UIPasteboard.general
        pasteboard.string = "\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)"
    })

    let apple = UIAlertAction(title: "Apple Maps", style: .default, handler: {
      (alert: UIAlertAction!) -> Void in
        let u = "http://maps.apple.com/?daddr=\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)"
        UIApplication.shared.openURL(NSURL(string: u)! as URL)
    })
    
    let google = UIAlertAction(title: "Google Maps", style: .default, handler: {
      (alert: UIAlertAction!) -> Void in
      
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
          UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)&directionsmode=driving")! as URL)

        } else {
          let link = "http://itunes.apple.com/us/app/id585027354"
          UIApplication.shared.openURL(NSURL(string: link)! as URL)
          UIApplication.shared.isIdleTimerDisabled = true
        }
    })
    
    let waze = UIAlertAction(title: "Waze", style: .default, handler: {
      (alert: UIAlertAction!) -> Void in

        if UIApplication.shared.canOpenURL(NSURL(string: "waze://")! as URL) {
            UIApplication.shared.openURL(NSURL(string: "waze://?ll=\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)&navigate=yes")! as URL)
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            UIApplication.shared.openURL(NSURL(string: "http://itunes.apple.com/us/app/id323229106")! as URL)
            UIApplication.shared.isIdleTimerDisabled = true
        }
    })

    let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {
      (alert: UIAlertAction!) -> Void in
    })
    
    optionMenu.addAction(copy)
    optionMenu.addAction(apple)
    optionMenu.addAction(google)
    optionMenu.addAction(waze)
    optionMenu.addAction(cancelAction)
    
    self.present(optionMenu, animated: true, completion: nil)
  }
  
  // pass object to details view
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDescription" {
    
      if let description: DescriptionViewController = segue.destination as? DescriptionViewController {
        navigationItem.title = ""
        description.point = self.point
      }
    }
  }
  
}
