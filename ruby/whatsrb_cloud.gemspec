# frozen_string_literal: true

require_relative 'lib/whatsrb_cloud/version'

Gem::Specification.new do |spec|
  spec.name          = 'whatsrb_cloud'
  spec.version       = WhatsrbCloud::VERSION
  spec.authors       = ['SerylLns']
  spec.email         = ['contact@whatsrb.com']

  spec.summary       = 'Ruby SDK for the WhatsRB Cloud API'
  spec.description   = 'Official Ruby client for the WhatsRB Cloud API. ' \
                       'Send WhatsApp messages, manage sessions, and handle webhooks.'
  spec.homepage      = 'https://github.com/SerylLns/whatsrb-cloud-ruby'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri']   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
