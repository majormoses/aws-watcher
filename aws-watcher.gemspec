Gem::Specification.new do |s|
  s.name        = 'aws-watcher'
  s.version     = '0.1.0'
  s.summary     = 'AWS Watcher tracks EC2 instances being started to ensure they bootstrap to chef'
  s.description = s.summary
  s.authors     = ['Ben Abrams']
  s.email       = 'me@benabrams.it'
  s.executables = ['aws_watcher.rb']
  s.files       = Dir.glob("{bin,lib}/**/*.rb")
  s.homepage    = 'https://github.com/majormoses/aws-watcher'
  s.license     = 'MIT'

  s.add_development_dependency 'bundler', '~> 1.12'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rubocop', '~> 0.46.0'

  s.add_runtime_dependency 'aws-sdk-core', '~> 2.0'
  s.add_runtime_dependency 'chef-api', '~> 0.5'
  s.add_runtime_dependency 'chronic', '~> 0.10'
  s.add_runtime_dependency 'hipchat', '~> 1.5'
  s.add_runtime_dependency 'rest-client', '~> 2'
  s.add_runtime_dependency 'slack-poster', '~> 2.2'
  s.add_runtime_dependency 'trollop', '~> 2.1'
  s.add_runtime_dependency 'aws-cleaner', '~> 2'
end
