# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lambchop/version'

Gem::Specification.new do |spec|
  spec.name          = 'lambchop'
  spec.version       = Lambchop::VERSION
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sgwr_dts@yahoo.co.jp']
  spec.summary       = %q{It is a tool that invoke AWS Lambda function from the local machine as a normally script.}
  spec.description   = %q{It is a tool that invoke AWS Lambda function from the local machine as a normally script.}
  spec.homepage      = 'https://github.com/winebarrel/lambchop'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']


  spec.add_dependency 'aws-sdk-core', '~> 2.0.9'
  spec.add_dependency 'rubyzip', '>= 1.0.0'
  spec.add_dependency 'diffy'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
