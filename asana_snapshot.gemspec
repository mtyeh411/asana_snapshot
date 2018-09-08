Gem::Specification.new do |s|
  s.version     = '0.1.1'

  s.name          = 'asana_snapshot'
  s.summary       = 'Save snapshots of Asana tasks.'
  s.description   = <<-EOF
    AsanaSnapshot wraps the official Asana ruby client to search for tasks, write them to text files, and check them into a git repository.
  EOF

  s.author        = 'Matt Yeh'
  s.email         = 'dev.mtyeh411@gmail.com'
  s.homepage      = 'https://github.com/mtyeh411/asana_snapshot'
  s.license       = 'MIT'

  s.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.executables   = ['snap']

  s.required_ruby_version = '>=2.4.2'
  s.add_runtime_dependency 'asana', '~> 0.8', '>= 0.8.0'
end
