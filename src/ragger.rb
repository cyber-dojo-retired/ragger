
class Ragger

  def initialize(_external)
  end

  def sha
    ENV['SHA']
  end

  def colour(id, filename, content, stdout, stderr, status)
    'red'
  end

  private

end
