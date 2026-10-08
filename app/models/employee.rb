class Employee < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :appointments

  belongs_to :enterprise
  has_one_attached :photo

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }

  def display_name
    [ first_name, last_name ].compact_blank.join(" ").presence || email_address
  end
end
