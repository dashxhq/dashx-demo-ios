app_ios_deployment_target = Gem::Version.new('13.0')

platform :ios, app_ios_deployment_target.version

abstract_target 'DashX Demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DashX Demo
  pod 'DashX'
  pod 'FirebaseMessaging'

  target 'DashX Demo Staging' do
    # Pods for Staging
  end

  target 'DashX Demo Production' do
    # Pods for Production
  end

  target 'DashX DemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DashX DemoUITests' do
    # Pods for testing
  end

  post_install do |installer|
    # Let Pods targets inherit deployment target from the app
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |configuration|
         pod_ios_deployment_target = Gem::Version.new(configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
         configuration.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET' if pod_ios_deployment_target <= app_ios_deployment_target
      end
    end
  end
end
