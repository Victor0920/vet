class Employee < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :enterprise

  normalizes :email_address, with: ->(e) { e.strip.downcase }


  def display_name
    [ first_name, last_name ].compact_blank.join(" ").presence || email_address
  end
end
