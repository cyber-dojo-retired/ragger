require_relative 'test_base'

class Id58TestBaseTest < TestBase

  def self.id58_prefix
    '89876'
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'C80',
  'test-id is available via environment variable' do
    assert_equal '89876C80', ENV['TEST_ID58']
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '57B',
  'test-id is available via a method',
  'and is the id58_prefix concatenated with the id58' do
    assert_equal '8987657B', test_id58
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '18F',
  'test-name is available via a method' do
    assert_equal 'test-name is available via a method', test_name58
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'D30',
  'test-name can be long',
  'and split over many',
  'comma separated lines',
  'and will automatically be',
  'joined with spaces' do
    expected = [
      'test-name can be long',
      'and split over many',
      'comma separated lines',
      'and will automatically be',
      'joined with spaces'
    ].join(' ')
    assert_equal expected, test_name58
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'D31', %w(
    test-name can be long
    and split over many lines
    with %w syntax
    and will automatically be
    joined with spaces
  ) do
    expected = [
      'test-name can be long',
      'and split over many lines',
      'with %w syntax',
      'and will automatically be',
      'joined with spaces'
    ].join(' ')
    assert_equal expected, test_name58
  end

end
