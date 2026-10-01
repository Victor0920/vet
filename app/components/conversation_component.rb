# frozen_string_literal: true

class ConversationComponent < ViewComponent::Base
  def initialize(conversation:, link_messages: true)
    @conversation = conversation
    @linkMessages = link_messages
  end
end
