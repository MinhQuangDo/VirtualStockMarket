# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'VirtualStockMarket' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

	pod 'Charts'

  # Pods for VirtualStockMarket
# add the Firebase pod for Google Analytics
	pod 'Firebase/Analytics'
	pod 'Firebase/Auth'
	pod 'Firebase/Core'
	pod 'Firebase/Firestore'
# add pods for any other desired Firebase products
# https://firebase.google.com/docs/ios/setup#available-pods


end
post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['SWIFT_VERSION'] = '5.0'
end
end
end
