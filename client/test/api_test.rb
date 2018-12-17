require_relative '../src/http_json_service'
require_relative 'test_base'

class ApiTest < TestBase

  def self.hex_prefix
    '3759D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # red, amber, green
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D1', 'red' do
    colour_rb(python_pytest_colour_rb, python_pytest_stdout_red, '', '0')
    assert_colour 'red'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D2', 'amber' do
    colour_rb(python_pytest_colour_rb, python_pytest_stdout_amber, '', '0')
    assert_colour 'amber'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D3', 'green' do
    colour_rb(python_pytest_colour_rb, python_pytest_stdout_green, '', '0')
    assert_colour 'green'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # robustness
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F0',
  'call to non existent method becomes exception' do
    assert_exception({}.to_json, 'does_not_exist')
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

  include HttpJsonService

  def hostname
    ENV['RAGGER_SERVICE_NAME']
  end

  def port
    ENV['RAGGER_SERVICE_PORT'].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_exception(jsoned_args, method_name = 'colour_ruby')
    json = http(method_name, jsoned_args) { |uri|
      Net::HTTP::Get.new(uri)
    }
    refute_nil json['exception']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def ro(content)
    {
       'content' => content,
      'readonly' => false
    }
  end

end
