class Room < ApplicationRecord
  include Colorable

  belongs_to :store
  has_many :appointments, dependent: :destroy
end
