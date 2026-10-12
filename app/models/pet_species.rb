class PetSpecies < ApplicationRecord
  has_many :pets, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  # Label in the current language; falls back to "Guinea pig" style if a translation is missing
  def display_name
    I18n.t(name, scope: "pets.species", default: name.humanize)
  end
end
