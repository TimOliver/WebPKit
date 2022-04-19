Pod::Spec.new do |s|
  s.name     = 'WebPKit'
  s.version  = '1.0.0'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A framework that implements encoding and decoding WebP files on all of Apple\'s platforms.'
  s.homepage = 'https://github.com/TimOliver/WebPKit'
  s.author   = 'Tim Oliver'
  s.source   = { :git => 'https://github.com/TimOliver/WebPKit.git', :tag => s.version }
  s.source_files = 'WebPKit/**/*.{swift}'
  s.swift_version = '5.0'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.dependency 'libwebp'
end
