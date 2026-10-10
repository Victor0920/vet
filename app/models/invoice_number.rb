# Builds an invoice number from the enterprise's schema.
# "[y]-[s]/[n]" for store "PK", dated 2026, 9th invoice of the year → "2026-PK/9"
class InvoiceNumber
  TOKENS = %w[s y m d n].freeze

  def initialize(enterprise:, store:, date:, rectification: false)
    @enterprise = enterprise
    @store = store
    @date = date.to_date
    @rectification = rectification
  end

  # Rectificativas use their own schema, or "R" + the invoice schema when it's left blank
  def schema
    if @rectification
      @enterprise.rectification_number_schema.presence || "R#{@enterprise.invoice_number_schema}"
    else
      @enterprise.invoice_number_schema
    end
  end

  def uses_store?
    schema.include?("[s]")
  end

  # The counter this number belongs to. Each series counts from 1 on its own:
  # invoices vs rectificativas, per store (only when [s] is used), per year or month.
  # e.g. "F/PK/2026" or "R/2026-10"
  def series
    period = @enterprise.invoice_counter_reset_monthly? ? @date.strftime("%Y-%m") : @date.year.to_s
    [ @rectification ? "R" : "F", (@store.invoice_code if uses_store?), period ].compact.join("/")
  end

  def next_sequence
    @enterprise.invoices.where(series: series).maximum(:sequence_number).to_i + 1
  end

  # nil when the schema needs the store's code and the store has none
  def format(sequence = next_sequence)
    return if uses_store? && @store.invoice_code.blank?

    schema.gsub(/\[(\w+)\]/) do |token|
      case $1
      when "s" then @store.invoice_code
      when "y" then @date.year.to_s
      when "m" then @date.strftime("%m")
      when "d" then @date.strftime("%d")
      when "n" then sequence.to_s
      when /\An(\d)\z/ then sequence.to_s.rjust($1.to_i, "0") # [n4] → "0009"
      else token
      end
    end
  end
end
