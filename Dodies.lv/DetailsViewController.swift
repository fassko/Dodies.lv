//
//  Details.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import UIKit

import Fabric
import Crashlytics
import Kingfisher
import Localize_Swift

class DetailsViewController: UIViewController {

  var point: DodiesAnnotation!
  
  @IBOutlet weak var desc: UITextView!
  @IBOutlet weak var coordinatesButton: UIButton!
  @IBOutlet weak var lenght: UILabel!
  @IBOutlet weak var checked: UILabel!
  @IBOutlet weak var details: UIBarButtonItem!
  
  @IBOutlet weak var lengthTitle: UILabel!
  @IBOutlet weak var checkedTitle: UILabel!
  
  @IBOutlet weak var image: UIImageView?
  
  @IBOutlet var descHeight: NSLayoutConstraint!
  
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
    
    desc.sizeToFit()
    desc.layoutIfNeeded()
    descHeight.constant = desc.sizeThatFits(CGSize(width: desc.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
    

    self.automaticallyAdjustsScrollViewInsets = false
    
    coordinatesButton.setTitle("\(String(format: "%.5f",point.coordinate.latitude)), \(String(format: "%.5f",point.coordinate.longitude))", for: UIControlState.normal)
    
    
    if point.km == "" {
      lenght.isHidden = true
      lengthTitle.isHidden = true
    } else {
      lenght.text = "\(point.km) km"
    }
    
    let formatterFrom = DateFormatter()
    formatterFrom.dateFormat = "yyyy-MM-dd"
    
    if let date = formatterFrom.date(from: point.dat) {
      let formatter = DateFormatter()
      formatter.dateFormat = "mm.dd.yyyy"
      checked.text = formatter.string(from: date)
    } else {
      checkedTitle.isHidden = true
      checked.isHidden = true
    }
    
    if point.img != "" {
      image?.kf.indicatorType = .activity
      let processor = RoundCornerImageProcessor(cornerRadius: 10)
      image?.kf.setImage(with: URL(string: point.img), options: [.transition(.fade(0.2)), .processor(processor)])
    } else {
      image?.isHidden = true
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    Answers.logContentView(withName: "Details",
                      contentType: "DodiesDetails",
                      contentId: point.name,
                      customAttributes: ["name": point.name, "description": point.description])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  @IBAction func showDescription(_ sender: Any) {
    if !point.url.isEmpty {
      performSegue(withIdentifier: "showDescription", sender: self)
    } else {
      let alert = UIAlertController(title: "Dodies.lv", message: "Sorry, but description isn't ready yet.".localized(), preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  @IBAction func openNavigation(_ sender: Any) {
    let optionMenu = UIAlertController(title: nil, message: "Navigate with".localized(), preferredStyle: .actionSheet)
    
    optionMenu.popoverPresentationController?.sourceView = coordinatesButton
    
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
  
  override func viewDidLayoutSubviews() {
    caluclateTextViewHeight()
  }
  
  override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    caluclateTextViewHeight()
  }
  
  fileprivate func caluclateTextViewHeight() {
    let size: CGSize = desc.sizeThatFits(CGSize(width: desc.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
    let insets: UIEdgeInsets = desc.textContainerInset
    descHeight.constant = size.height + insets.top + insets.bottom
  }
  
}
