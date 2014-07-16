Gem::Specification.new do |spec|
  spec.name         = 'where_conditioner'
  spec.version      = '1.1.2'
  spec.date         = Date.today.to_s
  spec.summary      = "Where Conditioner"
  spec.description  = "Where Conditioner allows you to write conditional `where` expressions in a DRY manner."
  spec.authors      = ["Tony Novak", "Jonathan Aizen"]
  spec.email        = 'tony@amitree.com'
  spec.files        = Dir["{lib,spec,vendor}/**/*", "[A-Z]*"] - ["Gemfile.lock"]
  spec.homepage     = 'http://rubygems.org/gems/where_conditioner'
  spec.license      = 'MIT'

  spec.add_runtime_dependency 'activerecord', '>= 4.0.0'
  spec.add_development_dependency 'rspec-rails', '>= 3.0.0.beta'
end
