
# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'ARABAH' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

#   Pods for ARABAH
  pod 'RangeSeekSlider'
  pod 'Charts'
  pod 'Cosmos'
  pod 'IQKeyboardManagerSwift'
  pod 'CountryPickerView'
  pod 'AdvancedPageControl'
  pod 'SwiftMessages'
  pod 'SDWebImage'
  pod 'SwiftMessageBar'
  pod 'MBProgressHUD'
  pod 'PhoneNumberKit'
  pod 'GooglePlaces'
  pod 'GoogleMaps'
  pod 'Socket.IO-Client-Swift'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'MercariQRScanner'
  pod 'ShimmerSwift'
  pod 'SkeletonView'

  # Target for unit tests
  target 'ARABAHTests' do
    inherit! :search_paths
    # Add test-specific pods here if needed
  end

  # Target for UI tests
  target 'ARABAHUITests' do
    inherit! :search_paths
    # Add UI test-specific pods here if needed
  end
end

# Post-install hook to set the iOS deployment target
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
