# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Fixed list of species. `name` is a stable key; the label comes from
# config/locales (pets.species.<name>), so add a translation when adding one here.
%w[
  dog cat rabbit ferret guinea_pig hamster gerbil rat mouse chinchilla degu hedgehog squirrel
  bird turtle lizard snake fish
  horse donkey goat sheep pig cow chicken
  other
].each { |name| PetSpecies.find_or_create_by!(name: name) }
