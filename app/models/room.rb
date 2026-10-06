class Room < ApplicationRecord
  belongs_to :store
  has_many :appointments, dependent: :destroy
end
