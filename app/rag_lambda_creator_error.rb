# frozen_string_literal: true

class RagLambdaCreatorError < StandardError

  def initialize(message, info, source = nil)
    @message = message
    @info = info
    @source = source
    super(message)
  end

  attr_reader :message, :info, :source

end
