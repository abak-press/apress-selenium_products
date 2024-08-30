lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apress/selenium_products/version'

Gem::Specification.new do |spec|
  spec.name          = 'apress-selenium_products'
  spec.version       = Apress::SeleniumProducts::VERSION
  spec.authors       = ['Fyodor Parmanchukov']
  spec.email         = ['rezerbit@gmail.ru']

  spec.summary       = 'Selenium products gem'
  spec.description   = 'Cross-project products autotests'
  spec.homepage      = 'https://github.com/abak-press/apress-selenium_products'

  spec.files       	 = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'page-object', '~> 2.0.0' # В 2.1 выпилена поддержка Selenium
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'rspec'
  spec.add_runtime_dependency 'selenium-webdriver'
  spec.add_runtime_dependency 'pry-byebug'
end
