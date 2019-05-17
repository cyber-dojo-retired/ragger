require_relative 'test_base'

class FeatureRedAmberGreenTest < TestBase

  def self.hex_prefix
    'C608A'
  end

  # - - - - - - - - - - - - - - - - -

  test '6A1', 'red' do
    colour_rb(python_pytest_colour_rb, python_pytest_stdout_red, '', '0')
    assert_colour 'red'
  end

  test '6A2', 'amber' do
    colour_rb(python_pytest_colour_rb, python_pytest_stdout_amber, '', '0')
    assert_colour 'amber'
  end

  test '6A3', 'green' do
    colour_rb(python_pytest_colour_rb, python_pytest_stdout_green, '', '0')
    assert_colour 'amber'
  end

end