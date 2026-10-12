# frozen_string_literal: true

class TopNavComponent < ViewComponent::Base
  def initialize
    @enterprise = Current.enterprise
    @employee = Current.employee
    @unread_conversations = @enterprise ? @enterprise.conversations.with_unread.count : 0
  end
end
