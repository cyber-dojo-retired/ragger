require_relative 'test_base'

class FeatureRedAmberGreenTest < TestBase

  def self.hex_prefix
    'C60'
  end

  # - - - - - - - - - - - - - - - - -

  test '6A1', 'red' do
    colour(python_pytest_image_name, id, python_pytest_stdout_red, '', '0')
    assert red?
  end

  test '6A2', 'amber' do
    colour(python_pytest_image_name, id, python_pytest_stdout_amber, '', '0')
    assert amber?
  end

  test '6A3', 'green' do
    colour(python_pytest_image_name, id, python_pytest_stdout_green, '', '0')
    assert green?
  end

  def python_pytest_image_name
    'cyberdojofoundation/python_pytest'
  end

end
