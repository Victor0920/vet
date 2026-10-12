class Pet < ApplicationRecord
  belongs_to :customer
  has_one_attached :photo
  belongs_to :usual_employee, class_name: "Employee", optional: true
  has_many :pet_weights, dependent: :destroy

  validate :usual_employee_belongs_to_enterprise

  private

  def usual_employee_belongs_to_enterprise
    return if usual_employee.nil? || usual_employee.enterprise_id == customer&.enterprise_id
    errors.add(:usual_employee, :invalid)
  end
end
