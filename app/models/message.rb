class Message < ApplicationRecord
  belongs_to :conversation, touch: true

  scope :unread, -> { user.where(read_at: nil) }

  # attribute :sender, :integer
  def sender=(value)
    super(value.is_a?(String) ? value.to_i : value)
  end

  # Even though the value stored is a number, it automatically changes the "visible value" when querying the ddbb
  enum :sender, { user: 0, bot: 1, admin: 2 }

  def unread?
    user? && read_at.nil?
  end

  after_create_commit -> { conversation.customer.enterprise.broadcast_unread_conversations }, if: :user?
end
