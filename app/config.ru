$stdout.sync = true
$stderr.sync = true

unless ENV['NO_PROMETHEUS']
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

require_relative 'externals'
require_relative 'rack_dispatcher'
require_relative 'traffic_light'
externals = Externals.new
traffic_light = TrafficLight.new(externals)
dispatcher = RackDispatcher.new(traffic_light)
require 'rack'
run dispatcher
