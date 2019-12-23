require_relative 'test_base'
require 'oj'

class ShaTest < TestBase

  def self.id58_prefix
    'FB3'
  end

  # - - - - - - - - - - - - - - - - -

  test '190', %w( sha is exposed via API ) do
    s = traffic_light.sha
    assert sha?(s), s
  end

end
