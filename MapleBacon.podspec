Pod::Spec.new do |s|
  s.name             = 'MapleBacon'
  s.version          = '5.3.1'
  s.swift_version    = '5.0'
  s.summary          = 'A lightweight and fast image downloading library iOS.'

  s.description      = <<-DESC
 A lightweight and fast image downloading library iOS. Background downloads, caching and transforms.
  DESC

  s.homepage         = 'https://github.com/JanGorman/MapleBacon'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Jan Gorman': 'gorman.jan@gmail.com' }
  s.source           = { git: 'https://github.com/JanGorman/MapleBacon.git',
                         tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/JanGorman'

  s.ios.deployment_target = '10.0'

  s.source_files = 'MapleBacon/**/*.swift'
end
