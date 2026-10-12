class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  # Who wrote it; only for sender "employee", and optional (older messages have none)
  belongs_to :employee, optional: true

  enum :sender, { customer: 0, employee: 1 }

  validates :employee, absence: true, if: :customer?

  scope :unread, -> { customer.where(read_at: nil) }

  after_create_commit -> { conversation.customer.enterprise.broadcast_unread_conversations }, if: :customer?

  def unread?
    customer? && read_at.nil?
  end
end
