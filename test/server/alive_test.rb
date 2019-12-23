require_relative 'test_base'

class AliveTest < TestBase

  def self.id58_prefix
    'A86'
  end

  # - - - - - - - - - - - - - - - - -

  test '15A',
  %w( its alive ) do
    assert traffic_light.alive?
  end

end
