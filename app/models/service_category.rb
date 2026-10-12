class ServiceCategory < ApplicationRecord
  include TracksUpdatedBy
  include Colorable

  has_many :services, dependent: :nullify # deleting the category leaves its services uncategorized
  belongs_to :enterprise
end
