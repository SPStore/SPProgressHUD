Pod::Spec.new do |spec|

  spec.name         = "SPProgressHUD"
  spec.version      = "0.0.1"
  spec.summary      = "展示一个简单的显示器窗口,包含了指示器,可选的文本消息,进度条,成功、失败等图片."


  spec.homepage     = "https://github.com/SPStore/SPProgressHUD"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license      = "MIT"
  spec.license      = { :type => "MIT", :file => "LICENSE" }


  spec.author             = { "乐升平" => "lesp163@163.com" }


  spec.platform     = :ios
  spec.platform     = :ios, "8.0"

  spec.ios.deployment_target = "8.0"


  spec.source       = { :git => "https://github.com/SPStore/SPProgressHUD.git", :tag => spec.version }


  spec.source_files  = "SPProgressHUD"
  spec.exclude_files = "Classes/Exclude"

end
