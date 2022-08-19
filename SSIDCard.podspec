#
# Be sure to run `pod lib lint SSIDCard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SSIDCard'
  s.version          = '1.4.2'
  s.summary          = '扫描识别中国二代身份证'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 通过扫描中国二代身份证，识别姓名和身份证号.
                       DESC

  s.homepage         = 'https://github.com/sansansisi'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '毵毵肆肆' => 'zhangjiamingcoder@gmail.com' }
  s.source           = { :git => 'https://github.com/sansansisi/SSIDCard.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = "SSIDCard/Classes/Public/**/*", "SSIDCard/Lib", 'SSIDCard/Classes/Private/Header/**/*.h'
  s.resources = "SSIDCard/Resource/**"
  s.framework  = "UIKit","Photos","AVFoundation","CoreMedia","CoreVideo"
  s.requires_arc = true
  s.ios.vendored_library = 'SSIDCard/Lib/*.a'
  # s.ios.vendored_frameworks = 'SSIDCard/Frameworks/*.framework'
  s.public_header_files = 'SSIDCard/Classes/Public/**/*.h'
  s.dependency 'OpenCV'
  
end
