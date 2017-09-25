Pod::Spec.new do |s|
  s.name             = "URLNavigator"
  s.version          = "1.3.0"
  s.summary          = "⛵️ Elegant URL Routing for Swift"
  s.homepage         = "https://github.com/devxoul/URLNavigator"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Suyeol Jeon" => "devxoul@gmail.com" }
  s.source           = { :git => "https://github.com/devxoul/URLNavigator.git",
                         :tag => s.version.to_s }
  s.source_files     = "Sources/**/*.swift"
  s.frameworks       = 'UIKit', 'Foundation'
  s.requires_arc     = true

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
end
