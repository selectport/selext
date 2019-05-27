# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'selext/version'

Gem::Specification.new do |spec|
  spec.name          = "selext"
  spec.version       = Selext.version
  spec.authors       = ["Scott Eckenrode"]
  spec.email         = ["scott@selectport.com"]

  spec.summary       = %q{SelectPort Selext Application Framework}
  spec.description   = %q{Provides a robust application framework for both web and non-ui appservices.}
  spec.homepage      = "https://github.com/selectport/selext"
  spec.license       = "Nonstandard"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.executables   = []

  spec.add_dependency             "concurrent-ruby", "~>1.1",   ">= 1.1.5"

  spec.add_development_dependency "bundler",         "~> 1.17", ">= 1.17.2"
  spec.add_development_dependency "rake",            "~> 12.3"
  spec.add_development_dependency "rspec",           "~> 3.8"
  spec.add_development_dependency "activesupport",   "~> 5.2",  ">= 5.2.3"
 
end
