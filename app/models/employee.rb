class Employee < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # an employee can be part of multiple companies
  has_many :employments, dependent: :destroy
  has_many :enterprises, through: :employments

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
