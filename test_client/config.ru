require 'rack'
require_relative 'src/externals'
require_relative 'src/demo'

externals = Externals.new
run Demo.new(externals)
