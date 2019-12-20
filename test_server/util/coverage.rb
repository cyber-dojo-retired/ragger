require 'simplecov'

def app_root
  File.expand_path('../..', __dir__) # eg /app
end

def is_test?(filename)
  filename.start_with?("#{app_root}/test/")
end

def is_app?(filename)
  filename.start_with?("#{app_root}/" ) && !is_test?(filename)
end

SimpleCov.start do
  #add_group('debug') {|src| puts src.filename; false; }
  add_group( 'app') { |src| is_app?(src.filename) }
  add_group('test') { |src| is_test?(src.filename) }
end
SimpleCov.root(app_root)
SimpleCov.coverage_dir(ENV['COVERAGE_ROOT'])
