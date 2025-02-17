require_relative 'lib/agile_rails_orders/version'

Gem::Specification.new do |spec|
  spec.name        = 'agile_rails_orders'
  spec.version     = AgileRailsOrders::VERSION
  spec.authors     = ['Damjan Rems']
  spec.email       = ['damjan.rems@gmail.com']
  spec.homepage    = 'https://github.com/agile-rails/agile-rails-orders'
  spec.summary     = 'Test example for AgileRails application development tool'
  spec.description = 'agile_rails_orders is Ruby on Rails gem which provides basic order purchase application'
  spec.license     = 'MIT'
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/agile-rails/agile-rails-orders'
  spec.metadata['changelog_uri'] = 'https://github.com/agile-rails/agile-rails-orders/changelog'

  #spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #  Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  #end
  spec.files = Dir['{app,config,db,lib}/**/*'] + %w[MIT-LICENSE Rakefile README.md agile_rails_orders.gemspec]

  spec.add_dependency 'rails' # , ">= 7"
  spec.add_dependency 'agile_rails' # , "> 0.0.1"
end
