class Store < ApplicationRecord
  belongs_to :enterprise
  has_many :appointments, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_one_attached :photo

  normalizes :invoice_code, with: ->(code) { code.strip.upcase.presence }
  validates :invoice_code, uniqueness: { scope: :enterprise_id }, format: { with: /\A[A-Z0-9]{1,10}\z/ }, allow_nil: true
end
