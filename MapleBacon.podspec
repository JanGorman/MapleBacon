Pod::Spec.new do |s|
  s.name         = "MapleBacon"
  s.version      = "1.0.2"
  s.summary      = "A delicious image download and caching library for iOS"
  s.description  = <<-DESC
                  A delicious image download and caching library for iOS. Background downloads, caching and scaling.
                   DESC
  s.homepage     = "https://github.com/zalando/MapleBacon/"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Dimitrios Georgakopoulos" => "dimitrios.georgakopoulos@zalando.de",
                     "Jan Gorman" => "jan.gorman@zalando.de",
                     "Ramy Kfoury" => "ramy.kfoury@zalando.de"
                   }

  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/zalando/MapleBacon.git", :tag => "1.0.2" }
  s.source_files = "Library/MapleBacon/MapleBacon/**/*.swift"
end