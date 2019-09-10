Pod::Spec.new do |spec|

  spec.name         = "SPProgressHUD"
  spec.version      = "1.0.0"
  spec.summary      = "指示器+toast功能"


  spec.homepage     = "https://github.com/SPStore/SPProgressHUD"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }


  spec.author             = { "乐升平" => "lesp163@163.com" }


  spec.platform     = :ios
  spec.platform     = :ios, "8.0"

  spec.ios.deployment_target = "8.0"


  spec.source       = { :git => "https://github.com/SPStore/SPProgressHUD.git", :tag => spec.version }


  spec.source_files  = "SPProgressHUD"
  spec.exclude_files = "Classes/Exclude"

end
