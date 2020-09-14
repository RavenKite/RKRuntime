
Pod::Spec.new do |s|

  s.name         = "RKRuntime"

  s.version      = "0.1.0"

  s.summary      = "Runtime category for NSObject."

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { '李沛倬' => 'lipeizhuo0528@outlook.com' }

  s.homepage     = "https://github.com/RavenKite/RKRuntime"

  s.source       = { :git => 'https://github.com/RavenKite/RKRuntime.git', :tag => s.version.to_s }

  s.ios.deployment_target = '6.0'
  
  s.osx.deployment_target = '10.12'

  s.source_files = 'Classes/**/*'

  s.frameworks   = 'Foundation'

end
