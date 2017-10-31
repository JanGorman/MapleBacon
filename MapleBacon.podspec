#
# Be sure to run `pod lib lint MapleBacon.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MapleBacon'
  s.version          = '5.0.0'
  s.summary          = 'A delicious image download and caching library for iOS.'

  s.description      = <<-DESC
 A delicious image download and caching library for iOS. Background downloads, caching and transforms.
                       DESC

  s.homepage         = 'https://github.com/JanGorman/MapleBacon'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jan Gorman' => 'gorman.jan@gmail.com' }
  s.source           = { :git => 'https://github.com/JanGorman/MapleBacon.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/JanGorman'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MapleBacon/MapleBacon/**/*'
end
