
Pod::Spec.new do |s|
  s.name             = 'MapleBacon'
  s.version          = '5.1.8'
  s.summary          = 'A delicious image download and caching library for iOS.'

  s.description      = <<-DESC
 A delicious image download and caching library for iOS. Background downloads, caching and transforms.
                       DESC

  s.homepage         = 'https://github.com/JanGorman/MapleBacon'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jan Gorman' => 'gorman.jan@gmail.com' }
  s.source           = { :git => 'https://github.com/JanGorman/MapleBacon.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/JanGorman'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MapleBacon/**/*'
end
