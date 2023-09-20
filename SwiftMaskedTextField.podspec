#
# Be sure to run `pod lib lint MaskedTextField.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftMaskedTextField'
  s.version          = '1.7'
  s.summary          = 'Easily manage masking in your UITextField.'
  s.description      = "Looking for simple Swift library to manage masking in UItextField? This one is for you:)"
  s.swift_version    = '5.0'
  s.homepage         = 'https://github.com/kunass2/MaskedTextField'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kunass2' => 'bartekss2@icloud.com' }
  s.source           = { :git => 'https://github.com/kunass2/MaskedTextField.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'MaskedTextField/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MaskedTextField' => ['MaskedTextField/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
