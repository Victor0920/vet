class Enterprise < ApplicationRecord
  has_many :employees, dependent: :destroy
  # dependent: :destroy because a product cannot live without it's enterprise
  has_many :products, dependent: :destroy
  has_many :product_categories, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :service_categories, dependent: :destroy
end
