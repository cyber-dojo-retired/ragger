require_relative 'test_base'
require_relative 'python_pytest'

class FeatureRedAmberGreenTest < TestBase

  def self.hex_prefix
    'C60'
  end

  # - - - - - - - - - - - - - - - - -

  test '6A1', 'red' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_RED, '', '0')
    assert_red
  end

  test '6A2', 'amber' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_AMBER, '', '0')
    assert_amber
  end

  test '6A3', 'green' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_GREEN, '', '0')
    assert_green
  end

end
