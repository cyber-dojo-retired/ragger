require 'rack'
require_relative 'externals'
require_relative 'demo'

externals = Externals.new
run Demo.new(externals)
