require_relative 'test_base'

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
    JSON.parse(traffic_light.ready?[2][0])['ready?']
  end

end
