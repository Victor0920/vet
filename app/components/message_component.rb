# frozen_string_literal: true

class MessageComponent < ViewComponent::Base
  def initialize(message:, linked: true, show_meta: true)
    @message = message
    @show_meta = show_meta
  end
end
