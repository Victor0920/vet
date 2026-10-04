class Pet < ApplicationRecord
  belongs_to :customer
  has_one_attached :photo
end
