require_relative 'hex_mini_test'
require_relative '../require_src'
require_src 'externals'
require_src 'ragger_service'

class TestBase < HexMiniTest

  def externals
    @externals ||= Externals.new
  end

  def ragger
    RaggerService.new(externals)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def sha
    ragger.sha
  end

  def alive?
    ragger.alive?
  end

  def ready?
    ragger.ready?
  end

  def colour(image_name, id, stdout, stderr, status)
    @colour = ragger.colour(image_name, id, stdout, stderr, status)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_sha(string)
    assert_equal 40, string.size
    string.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  def assert_colour(expected)
    assert_equal expected, @colour
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    hex_test_id[0..5]
  end

end
