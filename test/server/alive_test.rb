require_relative 'test_base'

class AliveTest < TestBase

  def self.hex_prefix
    'A86'
  end

  # - - - - - - - - - - - - - - - - -

  test '15A',
  %w( its alive ) do
    assert alive?
  end

  private

  def alive?
    JSON.parse(traffic_light.alive?[2][0])['alive?']
  end

end
