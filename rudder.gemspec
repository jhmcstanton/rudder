# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rudder/version'

Gem::Specification.new do |spec|
  spec.name          = 'rudder'
  spec.version       = Rudder::VERSION
  spec.authors       = ['Jim McStanton']
  spec.email         = ['jim@jhmcstanton.com']

  spec.summary       = 'Provides a DSL for building Concourse CI pipelines.'
  spec.homepage      = 'http://www.github.com/jhmcstanton/rudder'
  spec.license       = 'MIT'
  # rubocop:disable Layout/AlignHash, Metrics/LineLength
  spec.metadata      = {
    'homepage_uri'      => 'https://github.com/jhmcstanton/rudder',
    'changelog_uri'     => "https://github.com/jhmcstanton/rudder/blob/#{Rudder::VERSION}/CHANGELOG.md",
    'source_code_uri'   => 'https://github.com/jhmcstanton/rudder',
    'bug_tracker_uri'   => 'https://github.com/jhmcstanton/rudder/issues',
    'documentation_uri' => "https://www.rubydoc.info/gems/rudder/#{Rudder::VERSION}"
  }
  # rubocop:enable Layout/AlignHash, Metrics/LineLength

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.73.0'
  spec.add_development_dependency 'yard', '~> 0.9.2'
end
