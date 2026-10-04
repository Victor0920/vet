class Customer < ApplicationRecord
  has_many :pets, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_one_attached :photo
end
