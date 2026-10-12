class Employee < ApplicationRecord
  ROLES = %w[ admin vet atv recepcionist ].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :appointments

  belongs_to :enterprise
  has_one_attached :photo

  scope :active, -> { where(active: true) }

  normalizes :username, with: ->(name) { name.strip.downcase }
  normalizes :email_address, with: ->(e) { e.strip.downcase.presence }
  validates :username, presence: true, uniqueness: { scope: :enterprise_id },
                       format: { with: /\A[a-z0-9._-]{2,30}\z/ }
  validates :role, inclusion: { in: ROLES }, allow_blank: true
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }

  # Deactivating someone signs them out everywhere at once
  after_update { sessions.destroy_all if saved_change_to_active?(to: false) }

  def display_name
    [ first_name, last_name ].compact_blank.join(" ").presence || username
  end

  def admin?
    role == "admin"
  end
end
