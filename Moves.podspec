Pod::Spec.new do |s|

  s.name         = "Moves"
  s.version      = "1.7.0"
  s.summary      = "A custom view controller transition manager with animatable subviews"
  s.description  = "A custom view controller transition manager with animatable subviews. Make subviews leap in context from one view controller to the next"
  s.homepage     = "https://github.com/leojkwan/Moves"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Leo Kwan" => "leojkwan@gmail.com" }
  s.platform     = :ios, "8.0"
  s.swift_version = "5.0"

  s.source       = { :git => "https://github.com/leojkwan/Moves.git", :tag => s.version.to_s }
  s.source_files  = "Moves", "Moves/**/*.{h,m,swift}"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5' }
  s.dependency 'MiniObservable' , '~> 1.6.1'

end
