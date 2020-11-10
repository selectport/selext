require_relative 'lib/selext/version'

Gem::Specification.new do |spec|
  spec.name          = "selext"
  spec.version       = Selext::VERSION
  spec.authors       = ["Scott Eckenrode"]
  spec.email         = ["scott@selectport.com"]

  spec.summary       = %q{Convenience Library for Ruby Projects}
  spec.description   = %q{Selext provides a collection of configuration and
                          convenience functions
                         }
  spec.homepage      = "https://selectport.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://selectport.com"
  spec.metadata["changelog_uri"] = "https://selectport.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency               "activesupport", ">= 6.0.0"

  spec.add_development_dependency   "rspec", "~> 3.2"

end

