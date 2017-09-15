Pod::Spec.new do |s|

  s.name         = "Moves"
  s.version      = "1.0.0"
  s.summary      = "A custom view controller transition manager with animatable subviews"
  s.description  = "A custom view controller transition manager with animatable subviews. Make subviews leap in context from one view controller to the next"
  s.homepage     = "https://github.com/leojkwan/Moves"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Leo Kwan" => "leojkwan@gmail.com" }
  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/leojkwan/Moves.git", :tag => s.version.to_s }
  s.source_files  = "Moves", "Moves/**/*.{h,m,swift}"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }
  s.dependency 'MiniObservable' , '~> 1.1.0'

end
