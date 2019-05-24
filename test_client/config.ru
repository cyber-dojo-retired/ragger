require 'rack'
require_relative 'src/external'
require_relative 'src/demo'

run Demo.new(External.new)
