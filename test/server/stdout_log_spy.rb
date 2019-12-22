
class StdoutLogSpy

  def <<(string)
    spied << string
  end

  def spied
    @spied ||= []
  end

  def spied?(string)
    spied[0].include?(string)
  end

end
