class Customer < ApplicationRecord
  has_many :pets, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_one_attached :photo


  def full_name
    [ first_name, first_surname ].compact_blank.join(" ").presence || "Customer ##{id}"
  end
end
