Pod::Spec.new do |s|
  s.name = 'CalculaNative'
  s.version = '1.0.0'
  s.summary = 'Plugins nativos de Calcula: menu de Apple y Face ID'
  s.license = { :type => 'MIT' }
  s.homepage = 'https://legaoc.pro'
  s.author = 'Calcula'
  s.source = { :git => 'https://github.com/legaoc/psnlgastos-app.git', :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.swift'
  s.ios.deployment_target = '14.0'
  s.dependency 'Capacitor'
  s.swift_version = '5.1'
end
