//
//  Details.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import Foundation
import UIKit

import Kingfisher
import Localize_Swift
import Lightbox
import SafariServices
import HTMLString
import ImageSlideshow

class DetailsViewController: UIViewController, Storyboarded {

  var point: DodiesAnnotation!
  var dodiesPointDetails: DodiesPointDetails!
  
  @IBOutlet weak var desc: UITextView!
  @IBOutlet weak var coordinatesButton: UIButton!
  @IBOutlet weak var lenght: UILabel!
  @IBOutlet weak var checked: UILabel!
  
  @IBOutlet weak var lengthStackView: UIStackView!
  @IBOutlet weak var lengthTitle: UILabel!
  
  @IBOutlet weak var checkedStackView: UIStackView!
  @IBOutlet weak var checkedTitle: UILabel!
  
  @IBOutlet weak var slideShow: ImageSlideshow!
  
  @IBOutlet var descHeight: NSLayoutConstraint!
  
  @IBOutlet weak var navigationButton: DodiesButton!
  @IBOutlet weak var moreInfoButton: DodiesButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = point.name.removingHTMLEntities
    
    checkedTitle.text = "Checked".localized()
    lengthTitle.text = "Length".localized()
    
    navigationButton.setTitle("Navigation".localized())
    moreInfoButton.setTitle("More Info".localized())
    
    navigationItem.titleView = titleLabel
    
    desc.isScrollEnabled = false
    desc.text = dodiesPointDetails.description.removingHTMLEntities
    
    desc.sizeToFit()
    desc.layoutIfNeeded()
    descHeight.constant = desc.sizeThatFits(CGSize(width: desc.frame.size.width,
                                                   height: CGFloat.greatestFiniteMagnitude)).height
    desc.contentInsetAdjustmentBehavior = .never
    
    navigationButton.layer.cornerRadius = Constants.buttonCornerRadius
    moreInfoButton.layer.cornerRadius = Constants.buttonCornerRadius
    
    navigationButton.titleLabel?.adjustsFontForContentSizeCategory = true
    navigationButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    
    moreInfoButton.titleLabel?.adjustsFontForContentSizeCategory = true
    moreInfoButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    
    setupDetails()
    setupImage()
  }
  
  private func setupDetails() {
    let latitude = String(format: "%.5f", point.coordinate.latitude)
    let longitude = String(format: "%.5f", point.coordinate.longitude)
    coordinatesButton.setTitle("\(latitude), \(longitude)",
      for: UIControl.State.normal)
    
    if point.km == "" {
      lenght.isHidden = true
      lengthTitle.isHidden = true
    } else {
      lenght.text = "\(point.km) km"
    }
    
    let formatterFrom = DateFormatter()
    formatterFrom.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    if let date = formatterFrom.date(from: point.checkedDate) {
      let formatter = DateFormatter()
      formatter.dateFormat = "dd.MM.yyyy"
      checked.text = formatter.string(from: date)
    } else {
      checkedTitle.isHidden = true
      checked.isHidden = true
    }
  }
  
  private func setupImage() {
    guard let images = dodiesPointDetails.images else { return }
    
    let source = images.compactMap { image -> KingfisherSource? in
      guard let url = URL(string: image) else {
        return nil
      }
      
      return KingfisherSource(url: url, options: [.transition(.fade(0.5))])
    }
    
    if !source.isEmpty {
      slideShow.slideshowInterval = 5.0
      slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
      slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
      
      if source.count < 10 {
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor(named: "currentIndicator")
        pageControl.pageIndicatorTintColor = UIColor(named: "pageIndicator")
        slideShow.pageIndicator = pageControl
      } else {
        slideShow.pageIndicator = nil
      }
      
      slideShow.activityIndicator = DefaultActivityIndicator(style: .white, color: UIColor(named: "currentIndicator"))
      
      slideShow.setImageInputs(source)
      
      let recognizer = UITapGestureRecognizer(target: self, action: #selector(showGallery(_:)))
      slideShow.addGestureRecognizer(recognizer)
    } else {
      slideShow?.isHidden = true
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  @IBAction func showDescription(_ sender: Any) {
    guard !point.url.isEmpty, let url = URL(string: "https://dodies.lv/\(point.url)") else {
      let alert = UIAlertController(title: "Dodies.lv",
                                    message: "Sorry, but description isn't ready yet.".localized(),
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
      present(alert, animated: true, completion: nil)
      
      return
    }
      
    let safariViewController = SFSafariViewController(url: url)
    safariViewController.preferredBarTintColor = Constants.greenColor
    safariViewController.preferredControlTintColor = .white
    
    present(safariViewController, animated: true, completion: nil)
  }
  
  @IBAction func openNavigation(_ sender: Any) {
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    optionMenu.popoverPresentationController?.sourceView = coordinatesButton
    optionMenu.view.tintColor = Constants.lightGreen
    
    let copy = UIAlertAction(title: "Copy coordiantes".localized(), style: .default) { _ in
      let pasteboard = UIPasteboard.general
      pasteboard.string = "\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)"
      UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    let apple = UIAlertAction(title: "Apple Maps", style: .default) { _ in
      let path = "http://maps.apple.com/?daddr=\(self.point.coordinate.latitude),\(self.point.coordinate.longitude)"
      UIApplication.shared.open(URL(string: path)!, options: [:], completionHandler: nil)
    }
    
    let latitude = point.coordinate.latitude
    let longitude = point.coordinate.longitude

    let google = UIAlertAction(title: "Google Maps", style: .default) { _ in
      if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
        let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } else {
        let link = "http://itunes.apple.com/us/app/id585027354"
        UIApplication.shared.open(URL(string: link)!, options: [:], completionHandler: nil)
        UIApplication.shared.isIdleTimerDisabled = true
      }
    }

    let waze = UIAlertAction(title: "Waze", style: .default) { _ in
      if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
        let wazeURL = URL(string: "waze://?ll=\(latitude),\(longitude)&navigate=yes")!
        UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
        UIApplication.shared.isIdleTimerDisabled = true
      } else {
        let wazeDownloadURL = URL(string: "http://itunes.apple.com/us/app/id323229106")!
        UIApplication.shared.open(wazeDownloadURL, options: [:], completionHandler: nil)
        UIApplication.shared.isIdleTimerDisabled = true
      }
    }

    let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
    
    optionMenu.addAction(copy)
    optionMenu.addAction(apple)
    optionMenu.addAction(google)
    optionMenu.addAction(waze)
    optionMenu.addAction(cancelAction)
    
    present(optionMenu, animated: true, completion: nil)
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
  
  @objc func showGallery(_ sender: UITapGestureRecognizer) {
    guard let images = dodiesPointDetails.images, let pointTitle = point.title else { return }
    
    let source = images.compactMap { image -> LightboxImage? in
      guard let url = URL(string: image) else {
        return nil
      }
      
      return LightboxImage(imageURL: url, text: pointTitle)
    }

    LightboxConfig.CloseButton.text = "Close".localized()
  
    let lightboxController = LightboxController(images: source)
    lightboxController.dynamicBackground = true
    lightboxController.modalPresentationStyle = .fullScreen
    
    present(lightboxController, animated: true, completion: nil)
  }
  
}
