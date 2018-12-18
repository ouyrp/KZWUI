#
# Be sure to run `pod lib lint KZWUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KZWUI'
  s.version          = '1.0.3'
  s.summary          = 'A short description of KZWUI.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ouyrp/KZWUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ouyrp' => 'rp.ouyang001@bkjk.com' }
  s.source           = { :git => 'https://github.com/ouyrp/KZWUI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'KZWUI/Classes/KZWUI.h'
  s.subspec 'Content' do |ss|
      ss.source_files = 'KZWUI/Classes/**/*'
      ss.exclude_files = 'KZWUI/Classes/KZWUI.h'
      ss.resource_bundles = {
          'KZWUI' => 'KZWUI/Assets/*.xcassets'
      }
      ss.frameworks = 'UIKit', 'Security','MapKit' , 'WebKit', 'AudioToolbox'
      ss.dependency 'KZWUtils'
      ss.dependency 'Masonry'
      ss.dependency 'AFNetworking'
      ss.dependency 'MBProgressHUD'
  end
  
  
  # s.resource_bundles = {
  #   'KZWUI' => ['KZWUI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
