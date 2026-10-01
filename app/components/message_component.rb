# frozen_string_literal: true

class MessageComponent < ViewComponent::Base
  def initialize(message:, linked: true)
    @message = message
    @linked = linked
  end
end
