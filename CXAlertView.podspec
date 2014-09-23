Pod::Spec.new do |s|
  s.name         = "CXAlertView"
  s.version      = "1.1.0"
  s.summary      = "Custom alertView which allow you to add view as main content."
  s.homepage     = "https://github.com/ChrisXu1221/CXAlertView"
  s.license      = 'MIT'
  s.author       = { "ChrisXu" => "taterctl@gmail.com" }
  s.source       = { :git => "https://github.com/czeluff/CXAlertView.git", :tag => "1.1.0" }
  s.source_files = 'CXAlertView/*.{h,m}'
  s.platform     = :ios, '5.0'
  s.framework    = 'QuartzCore', 'CoreGraphics', 'Accelerate'
  s.requires_arc = true
  s.dependency 'LiveFrost', '~> 1.1'
end
