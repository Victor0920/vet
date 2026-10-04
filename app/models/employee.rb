class Employee < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :enterprise

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
