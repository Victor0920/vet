class Pet < ApplicationRecord
  belongs_to :customer
  has_one_attached :photo
  belongs_to :usual_employee, class_name: "Employee", optional: true
  belongs_to :pet_species, optional: true
  has_many :pet_weights, dependent: :destroy
  has_rich_text :notes

  # Every word has to match the pet (name, breed, microchip) or its owner (anything Customer.search looks at):
  # "luna garcia" finds Luna, owned by Ana García
  scope :search, ->(query) {
    query.to_s.split.reduce(all) do |pets, word|
      pattern = "%#{sanitize_sql_like(word)}%"
      pets.where("pets.name LIKE :pattern OR pets.breed LIKE :pattern OR pets.transponder_number LIKE :pattern", pattern: pattern)
          .or(pets.where(customer: Customer.search(word)))
    end
  }

  validate :usual_employee_belongs_to_enterprise

  private

  def usual_employee_belongs_to_enterprise
    return if usual_employee.nil? || usual_employee.enterprise_id == customer&.enterprise_id
    errors.add(:usual_employee, :invalid)
  end
end
