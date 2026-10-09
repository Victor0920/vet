class Service < ApplicationRecord
  include TracksUpdatedBy
  belongs_to :enterprise
  belongs_to :service_category

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :category_belongs_to_same_enterprise

  scope :search, ->(query) {
    query.to_s.split.reduce(all) do |services, word|
      pattern = "%#{sanitize_sql_like(word)}%"
      services.where("services.name LIKE :pattern OR services.description LIKE :pattern", pattern: pattern)
    end
  }

  private

  def category_belongs_to_same_enterprise
    if service_category && service_category.enterprise_id != enterprise_id
      errors.add(:service_category, "is not valid")
    end
  end
end
