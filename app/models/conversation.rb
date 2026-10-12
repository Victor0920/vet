class Conversation < ApplicationRecord
  belongs_to :customer
  has_many :messages, dependent: :delete_all
  validates :customer_id, uniqueness: true

  scope :search, ->(query) {
    query.to_s.split.reduce(all) do |conversations, word|
      pattern = "%#{sanitize_sql_like(word)}%"
      conversations.where(customer: Customer.search(word))
        .or(conversations.where(id: Message.where("messages.text LIKE ?", pattern).select(:conversation_id)))
    end
  }

  scope :with_unread, -> { where(id: Message.unread.select(:conversation_id)) }

  scope :unread_first, -> {
      order(Arel.sql(<<~SQL.squish) => :desc).order(updated_at: :desc)
        EXISTS (SELECT 1 FROM messages
                WHERE messages.conversation_id = conversations.id
                  AND messages.sender = #{Message.senders[:user]}
                  AND messages.read_at IS NULL)
      SQL
    }

  # Counted in Ruby: the index already loads the messages (includes), so this adds no query
  def unread_count
    messages.count(&:unread?)
  end

  def last_message
    messages.max_by(&:created_at)
  end

  # Opening the chat reads it. update_all: one UPDATE that skips touch (reading doesn't move the
  # chat up the inbox). It returns how many rows changed: no broadcast if nothing was unread
  def mark_read!
    return if messages.unread.update_all(read_at: Time.current).zero?

    customer.enterprise.broadcast_unread_conversations
  end
end
