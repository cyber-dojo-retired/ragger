require 'rack'
require_relative 'src/external'
require_relative 'src/demo'

external = External.new
run Demo.new(external)
