Pod::Spec.new do |s|
  s.name     = 'WebPKit'
  s.version  = '0.0.1'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A view controller that prompts users to enter a passcode.'
  s.homepage = 'https://github.com/TimOliver/WebPKit'
  s.author   = 'Tim Oliver'
  s.source   = { :git => 'https://github.com/TimOliver/WebPKit.git', :tag => s.version }
  s.source_files = 'WebPKit/**/*.{swift}'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.dependency 'libwebp'
end
