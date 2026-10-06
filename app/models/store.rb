class Store < ApplicationRecord
  belongs_to :enterprise
  has_many :appointments, dependent: :destroy
  has_many :rooms, dependent: :destroy
end
