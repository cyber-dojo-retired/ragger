require_relative 'test_base'
require_relative 'data/image_names'
require_relative '../src/well_formed_image_name'

class WellFormedImageNameTest < TestBase

  def self.hex_prefix
    'AF3'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '696', %w( malformed image_name is false ) do
    MALFORMED_IMAGE_NAMES.each do |image_name|
      refute well_formed_image_name?(image_name)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '697', %w( well-formed image_name is true ) do
    WELL_FORMED_IMAGE_NAMES.each { |image_name|
      assert well_formed_image_name?(image_name)
    }
  end

  private

  include Test::Data
  include WellFormedImageName

end
