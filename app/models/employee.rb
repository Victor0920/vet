class Employee < ApplicationRecord
  ROLES = %w[ admin vet atv recepcionist ].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :appointments
  has_many :messages, dependent: :nullify
  has_many :feedbacks, dependent: :nullify

  belongs_to :enterprise
  belongs_to :default_store, class_name: "Store", optional: true
  has_one_attached :photo

  scope :active, -> { where(active: true) }

  normalizes :username, with: ->(name) { name.strip.downcase }
  normalizes :email_address, with: ->(e) { e.strip.downcase.presence }
  validates :username, presence: true, uniqueness: { scope: :enterprise_id },
                       format: { with: /\A[a-z0-9._-]{2,30}\z/ }
  validates :role, inclusion: { in: ROLES }, allow_blank: true
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }
  validate :default_store_in_enterprise

  # Deactivating someone signs them out everywhere at once
  after_update { sessions.destroy_all if saved_change_to_active?(to: false) }

  def display_name
    [ first_name, last_name ].compact_blank.join(" ").presence || username
  end

  def admin?
    role == "admin"
  end

  private

  def default_store_in_enterprise
    if default_store && default_store.enterprise_id != enterprise_id
      errors.add(:default_store, :invalid)
    end
  end
end
