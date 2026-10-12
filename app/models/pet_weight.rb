class PetWeight < ApplicationRecord
  belongs_to :pet

  validates :weight, numericality: { greater_than: 0, less_than: 1000 }
  validates :measured_on, presence: true, uniqueness: { scope: :pet_id },
    comparison: { less_than_or_equal_to: ->(_) { Date.current }, allow_nil: true }
end
