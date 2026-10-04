class Enterprise < ApplicationRecord
  has_many :employments, dependent: :destroy
  has_many :employees, through: :employments
  # dependent: :destroy because a product cannot live without it's enterprise
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
end
