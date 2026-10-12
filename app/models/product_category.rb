class ProductCategory < ApplicationRecord
  include TracksUpdatedBy
  include Colorable

  has_many :products, dependent: :nullify # deleting the category leaves its products uncategorized
  belongs_to :enterprise
end
