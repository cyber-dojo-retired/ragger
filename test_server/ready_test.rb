require_relative 'test_base'
require 'oj'

class ReadyTest < TestBase

  def self.hex_prefix
    '872'
  end

  # - - - - - - - - - - - - - - - - -

  test '190',
  %w( its ready ) do
    assert ready?
  end

  private

  def ready?
    Oj.strict_load(traffic_light.ready?[2][0])['ready?']
  end

end
