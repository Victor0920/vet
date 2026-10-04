class Store < ApplicationRecord
  belongs_to :enterprise
  has_many :appointments, dependent: :destroy
end
