gem_directory = Gem::Specification.find_by_name("apress-selenium_eti").gem_dir
Dir["#{gem_directory}/lib/pages/**/*.rb"].each { |file| require file }
