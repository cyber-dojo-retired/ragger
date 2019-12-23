require_relative 'test_base'
require 'oj'

class ShaTest < TestBase

  def self.id58_prefix
    'FB3'
  end

  # - - - - - - - - - - - - - - - - -

  test '190', %w( sha is exposed via API ) do
    assert_sha traffic_light.sha
  end

end
