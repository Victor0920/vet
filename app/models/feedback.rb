class Feedback < ApplicationRecord
  IMAGE_TYPES = %w[ image/jpeg image/png image/webp image/gif ].freeze
  MAX_IMAGES = 5

  belongs_to :enterprise
  belongs_to :employee, optional: true # nil once the employee is deleted
  has_many_attached :images

  enum :kind, { problem: "problem", idea: "idea", question: "question", other: "other" }, prefix: true, validate: true
  enum :status, { received: "received", in_progress: "in_progress", resolved: "resolved" }, prefix: true, validate: true

  normalizes :message, with: ->(text) { text.strip }
  normalizes :page_url, :user_agent, with: ->(text) { text.first(500).presence }
  validates :message, presence: true, length: { maximum: 5000 }

  # The developer's reply (/developer/feedback/:id), shown to the employee on /help. One per feedback,
  # editable any time; responded_at follows it, and clearing the reply clears the date
  normalizes :response, with: ->(text) { text.strip.presence }
  validates :response, length: { maximum: 5000 }
  before_save { self.responded_at = response && Time.current if will_save_change_to_response? }
  validate :images_are_valid

  # Tells the developer by email, in the background so submitting stays fast
  after_create_commit -> { FeedbackMailer.submitted(self).deliver_later }

    private

  def images_are_valid
    errors.add(:images, :too_many_images, max: MAX_IMAGES) if images.size > MAX_IMAGES
    images.each do |image|
      errors.add(:images, :jpg_png_webp_or_gif_only) unless image.content_type.in?(IMAGE_TYPES)
      errors.add(:images, :image_too_big, max: "10 MB") if image.byte_size > 10.megabytes
    end
  end
end
