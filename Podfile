platform :ios, '9.0'
use_frameworks!

target 'Dodies.lv' do
  pod 'Alamofire'
  pod 'Mapbox-iOS-SDK'
  pod 'SwiftyJSON'
  pod 'Attributed'
  pod 'SwiftSpinner'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftyUserDefaults'
  pod 'RealmSwift'
  pod "AsyncSwift"
  pod 'GCDKit', :git => 'https://github.com/JohnEstropia/GCDKit.git', :branch => 'swift3_develop'
  pod 'Google/Analytics'
  pod 'FontAwesome.swift'
  pod 'LKAlertController'
  pod 'AlamofireImage'
  pod 'CocoaLumberjack/Swift'
  pod 'SwiftDate'
  pod 'Localize-Swift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end