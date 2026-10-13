class Store < ApplicationRecord
  belongs_to :enterprise
  has_many :appointments, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :opening_hours, dependent: :delete_all
  has_one_attached :photo
  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 320, 320 ], preprocessed: true
  end
  has_many :default_for_employees, class_name: "Employee", foreign_key: :default_store_id,
    inverse_of: :default_store, dependent: :nullify

  normalizes :invoice_code, with: ->(code) { code.strip.upcase.presence }
  validates :invoice_code, uniqueness: { scope: :enterprise_id }, format: { with: /\A[A-Z0-9]{1,10}\z/ }, allow_nil: true
  validate :logo_is_png_or_jpg

  attribute :remove_photo, :boolean, default: false
  attribute :remove_logo, :boolean, default: false

  before_save { self.photo = nil if remove_photo && photo.persisted? }
  before_save { self.logo = nil if remove_logo && logo.persisted? }

  # For automatic bookings: is one opening period covering the whole appointment?
  def open_between?(starts_at, ends_at)
    return false unless starts_at.to_date == ends_at.to_date

    opening_hours.where(weekday: starts_at.wday)
                 .where("opens_at <= ? AND closes_at >= ?", starts_at.strftime("%H:%M"), ends_at.strftime("%H:%M"))
                 .exists?
  end

  private

  def logo_is_png_or_jpg
    if logo.attached? && !logo.content_type.in?(%w[image/png image/jpeg])
      errors.add(:logo, :png_or_jpg_only)
    end
  end
end
