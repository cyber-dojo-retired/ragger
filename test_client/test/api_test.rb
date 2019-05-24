require_relative '../src/data/python_pytest'
require_relative 'test_base'

class ApiTest < TestBase

  def self.hex_prefix
    '375'
  end

  include Test::Data

  test '762', 'sha' do
    assert_sha(sha)
  end

  test '763', 'ready?' do
    assert ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # colour - red/amber/green
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D1', 'red' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_RED, '', '0')
    assert_colour 'red'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D2', 'amber' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_AMBER, '', '0')
    assert_colour 'amber'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D3', 'green' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_GREEN, '', '0')
    assert_colour 'green'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # colour - robustness
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F0', 'malformed image-name becomes exception' do
    error = assert_raises(RuntimeError) {
      colour(nil, id, PythonPytest::STDOUT_GREEN, '', '0')
    }
    json = JSON.parse(error.message)
    assert_equal '/colour', json['path']
    assert_equal 'RaggerService', json['class']
    assert_equal 'image_name is malformed', json['message']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F1', 'malformed id becomes exception' do
    error = assert_raises(RuntimeError) {
      colour('gcc', 'X'+id, PythonPytest::STDOUT_GREEN, '', '0')
    }
    json = JSON.parse(error.message)
    assert_equal '/colour', json['path']
    assert_equal 'RaggerService', json['class']
    assert_equal 'id is malformed', json['message']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F2', 'malformed stdout becomes exception' do
    error = assert_raises(RuntimeError) {
      colour('gcc', id, 999, '', '0')
    }
    json = JSON.parse(error.message)
    assert_equal '/colour', json['path']
    assert_equal 'RaggerService', json['class']
    assert_equal 'stdout is malformed', json['message']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F3', 'malformed stderr becomes exception' do
    error = assert_raises(RuntimeError) {
      colour('gcc', id, '', 999, '0')
    }
    json = JSON.parse(error.message)
    assert_equal '/colour', json['path']
    assert_equal 'RaggerService', json['class']
    assert_equal 'stderr is malformed', json['message']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F4', 'malformed status becomes exception' do
    error = assert_raises(RuntimeError) {
      colour('gcc', id, '', '', 999)
    }
    json = JSON.parse(error.message)
    assert_equal '/colour', json['path']
    assert_equal 'RaggerService', json['class']
    assert_equal 'status is malformed', json['message']
  end

  private

  def assert_exception(jsoned_args, method_name = 'colour_ruby')
    json = http(method_name, jsoned_args) { |uri|
      Net::HTTP::Get.new(uri)
    }
    refute_nil json['exception']
  end

end
