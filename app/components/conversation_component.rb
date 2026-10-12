# frozen_string_literal: true

class ConversationComponent < ViewComponent::Base
  def initialize(conversation:, link_messages: true)
    @conversation = conversation
  end

  # Like WhatsApp: consecutive messages from the same sender form a group, and only the last one
  # shows who sent it and when. A new group starts with another sender or after a 10-minute gap
  GROUP_GAP = 10.minutes

  def messages
    @messages ||= @conversation.messages.includes(:employee).order(:created_at).to_a
  end

  def show_meta?(message, next_message)
    next_message.nil? ||
      next_message.sender != message.sender ||
      next_message.created_at - message.created_at >= GROUP_GAP
  end
end
