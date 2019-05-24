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
    assert_exception('image_name is malformed') {
      colour(nil, id, '', '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F1', 'malformed id becomes exception' do
    assert_exception('id is malformed') {
      colour('gcc', 'X'+id, '', '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F2', 'malformed stdout becomes exception' do
    assert_exception('stdout is malformed') {
      colour('gcc', id, 999, '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F3', 'malformed stderr becomes exception' do
    assert_exception('stderr is malformed') {
      colour('gcc', id, '', 999, '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F4', 'malformed status becomes exception' do
    assert_exception('status is malformed') {
      colour('gcc', id, '', '', 999)
    }
  end

  private

  def assert_exception(expected_message)
    error = assert_raises(RuntimeError) { yield }
    json = JSON.parse(error.message)
    assert_equal '/colour', json['path']
    assert_equal 'RaggerService', json['class']
    assert_equal expected_message, json['message']
  end

end
