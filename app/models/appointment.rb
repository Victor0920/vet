class Appointment < ApplicationRecord
  belongs_to :customer
  belongs_to :pet
  belongs_to :employee
  belongs_to :store
  belongs_to :room
  belongs_to :enterprise, default: -> { Current.enterprise }

  validate :enterprise_matches_customer

  private

  def enterprise_matches_customer
    return if customer.nil? || enterprise.nil?
    errors.add(:enterprise, "must match the customer's enterprise") if customer.enterprise_id != enterprise_id
  end
end
