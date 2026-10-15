# pets.csv: the owner must already be a customer (import customers first), found by
# customer_document_number, else customer_email, else customer_phone
class Import::Pets < Import::Base
  REQUIRED_COLUMNS = %w[ name ].freeze
  TEXT_COLUMNS = %w[ name breed color transponder_number transponder_location ].freeze

  private

  def existing_records = @enterprise.pets

  def build(values, problems)
    Pet.new(values.slice(*TEXT_COLUMNS)).tap do |pet|
      pet.customer = owner(values, problems)
      pet.pet_species = species(values, problems)
      pet.sex = sex(values, problems)
      pet.born_on = date(values, "born_on", problems)
      pet.sterilized = boolean(values, "sterilized", problems)
      pet.notes = paragraphs(values["notes"]) if values["notes"]
    end
  end
  # The same pet: same microchip, or same name with the same owner
  def keys(pet)
    [
      tagged(:chip, pet.transponder_number.to_s.delete("^0-9A-Za-z")),
      tagged(:pet, ("#{pet.customer_id}/#{pet.name.downcase}" if pet.customer_id && pet.name))
    ].compact
  end

  # Exactly one customer: two sharing a phone (a family) is an error, not a guess
  def owner(values, problems)
    key = tagged(:document, normalized_document(values["customer_document_number"])) ||
          tagged(:email, normalized_email(values["customer_email"])) ||
          tagged(:phone, normalized_phone(values["customer_phone"]))
    matches = key ? owners.fetch(key, []) : []

    if matches.one?
      matches.first
    else
      problems << I18n.t(matches.none? ? "imports.problems.owner_not_found" : "imports.problems.owner_ambiguous")
      nil
    end
  end

  # Every customer under each way a row can point at them, loaded once for the whole file
  def owners
    @owners ||= @enterprise.customers.each_with_object({}) do |customer, index|
      [
        tagged(:document, normalized_document(customer.document_number)),
        tagged(:email, normalized_email(customer.email)),
        tagged(:phone, normalized_phone(customer.first_phone)),
        tagged(:phone, normalized_phone(customer.second_phone))
      ].compact.uniq.each { |key| (index[key] ||= []) << customer }
    end
  end

  # By its key ("dog") or its name in any of the app's languages ("Perro", "Dog")
  def species(values, problems)
    value = values["species"] or return
    found = species_by_name[value.downcase]
    problems << I18n.t("imports.problems.species", value: value) unless found
    found
  end

  def species_by_name
    @species_by_name ||= PetSpecies.all.each_with_object({}) do |species, index|
      names = I18n.available_locales.map { |locale| I18n.t(species.name, scope: "pets.species", locale: locale, default: species.name) }
      (names + [ species.name ]).each { |name| index[name.downcase] = species }
    end
  end

  # Plain text → the HTML Action Text stores, one <p> per line (escaped, so a "<" stays text)
  def paragraphs(text)
    text.split(/\r?\n/).map { |line| "<p>#{ERB::Util.html_escape(line)}</p>" }.join
  end
end
