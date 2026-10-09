class ServiceCategory < ApplicationRecord
  include TracksUpdatedBy
  include Colorable

  has_many :services, dependent: :restrict_with_error
  belongs_to :enterprise
end
