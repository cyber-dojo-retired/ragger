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

  test '2F1',
  'call to existing method with bad json becomes exception' do
    assert_exception('{x}')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F2',
  'call to existing method with missing argument becomes exception' do
    args = {
      # content:..., # <=====
      stdout:ro('s'),
      stderr:ro('s'),
      status:ro('0')
    }
    assert_exception(args.to_json)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F3',
  'call to existing method with bad argument type becomes exception' do
    args = {
      content:ro('s'),
      stdout:ro('s'),
      stderr:ro('s'),
      status:ro(['0']) # <=====
    }
    assert_exception(args.to_json)
  end

  private

  def assert_exception(jsoned_args, method_name = 'colour_ruby')
    json = http(method_name, jsoned_args) { |uri|
      Net::HTTP::Get.new(uri)
    }
    refute_nil json['exception']
  end

end
