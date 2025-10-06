Pod::Spec.new do |s|
  s.name         = 'gv_core'
  s.version      = '0.1.0'
  s.summary      = 'Guardian Voice UC native glue'
  s.source       = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'linphone-sdk', '~> 5.3'
  s.ios.deployment_target = '13.0'
end