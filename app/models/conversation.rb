class Conversation < ApplicationRecord
  belongs_to :user
  belongs_to :customer
  has_many :messages, dependent: :destroy

  def last_message
    messages.max_by(&:created_at)
  end
end
