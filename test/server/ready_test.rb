require_relative 'test_base'
require 'oj'

class ReadyTest < TestBase

  def self.id58_prefix
    '872'
  end

  # - - - - - - - - - - - - - - - - -

  test '190',
  %w( its ready ) do
    assert traffic_light.ready?
  end

end
