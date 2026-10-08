class Product < ApplicationRecord
  belongs_to :enterprise
  belongs_to :product_category

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :category_belongs_to_same_enterprise

  scope :search, ->(query) {
    query.to_s.split.reduce(all) do |products, word|
      pattern = "%#{sanitize_sql_like(word)}%"
      products.where("products.name LIKE :pattern OR products.description LIKE :pattern", pattern: pattern)
    end
  }

    private

  def category_belongs_to_same_enterprise
    if product_category && product_category.enterprise_id != enterprise_id
      errors.add(:product_category, "is not valid")
    end
  end
end
