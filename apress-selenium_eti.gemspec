lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apress/selenium_eti/version'

Gem::Specification.new do |spec|
  spec.name          = 'apress-selenium_eti'
  spec.version       = Apress::SeleniumEti::VERSION
  spec.authors       = ['Fyodor Parmanchukov']
  spec.email         = ['rezerbit@gmail.ru']

  spec.summary       = 'Selenium eti gem'
  spec.description   = 'Cross-project eti and mini-eti autotests'
  spec.homepage      = 'https://github.com/abak-press/abak-selenium_eti'

  spec.files       	 = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'page-object', '~> 2.0.0' # В 2.1 выпилена поддержка Selenium
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'rspec'
  spec.add_runtime_dependency 'selenium-webdriver'
  spec.add_runtime_dependency 'pry-byebug'
end
