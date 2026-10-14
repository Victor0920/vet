require "csv"

# Reads an import's CSV and works out, row by row, what importing it would do. Nothing is saved here.
# Each kind (Import::Customers, Import::Pets…) defines:
#   REQUIRED_COLUMNS  - headers the file must have
#   existing_records  - what's already in the database
#   build             - a new, unsaved record from one row
#   keys              - strings that make two records "the same" ("document:12345678Z")
class Import::Base
  # line: the row's number in the spreadsheet (1 is the headers)
  # status: :new (will be created), :duplicate (already there) or :error (see messages)
  Row = Struct.new(:line, :record, :status, :messages) do
    def new? = status == :new
    def duplicate? = status == :duplicate
    def error? = status == :error
  end

  SEXES = { "Male" => %w[ male macho hombre masculino ], "Female" => %w[ female hembra mujer femenino ] }.freeze
  YES = %w[ true 1 sí si yes x ].freeze
  NO = %w[ false 0 no ].freeze

  def initialize(import)
    @import = import
    @enterprise = import.enterprise
  end

  def rows
    check_columns
    existing = existing_records.flat_map { |record| keys(record) }.to_set
    seen = Set.new # keys of the new rows so far: the same customer twice in one file is a duplicate too

    table.each.with_index(2).filter_map do |csv_row, line|
      values = csv_row.to_h.transform_values { |value| clean(value) }
      next if values.values.none? # an empty line, or Excel's ";;;"

      problems = []
      record = build(values, problems)
      record_keys = keys(record)

      if record_keys.any? { |key| existing.include?(key) || seen.include?(key) }
        Row.new(line, record, :duplicate, [])
      elsif (messages = problems.presence || record_errors(record)).any?
        Row.new(line, record, :error, messages)
      else
        seen.merge(record_keys)
        Row.new(line, record, :new, [])
      end
    end
  end

  private

  def check_columns
    if table.size > Import::MAX_ROWS
      raise Import::Unreadable, I18n.t("imports.unreadable.too_many_rows", max: Import::MAX_ROWS)
    end

    missing = self.class::REQUIRED_COLUMNS - table.headers
    if missing.any?
      raise Import::Unreadable, I18n.t("imports.unreadable.missing_columns", columns: missing.join(", "))
    end
  end

  # Headers lowercased and trimmed, so "First_Name " still matches first_name
  def table
    @table ||= CSV.parse(text, headers: true, col_sep: separator, skip_blanks: true,
                               header_converters: ->(header) { header.to_s.strip.downcase })
  rescue CSV::MalformedCSVError => error
    raise Import::Unreadable, I18n.t("imports.unreadable.malformed", line: error.line_number)
  end

  # Excel on Windows saves CSVs as Windows-1252, not UTF-8: convert those so accents survive
  def text
    @text ||= begin
      raw = @import.file.download.force_encoding("UTF-8")
      raw = raw.force_encoding("Windows-1252").encode("UTF-8") unless raw.valid_encoding?
      raw.delete_prefix("\uFEFF")
    end
  end

  # Spanish Excel separates with ";", everything else with ","
  def separator
    header = text.each_line.first.to_s
    header.count(";") > header.count(",") ? ";" : ","
  end

  # "  Ana " → "Ana", "" → nil, and undoes the "'" DataExport puts before formula-like values
  def clean(value)
    value = value.to_s.strip
    value = value.delete_prefix("'") if value.match?(/\A'[=+\-@]/)
    value.presence
  end

  def record_errors(record)
    record.valid? ? [] : record.errors.full_messages
  end

  def problem(type, column, value)
    I18n.t("imports.problems.#{type}", column: column, value: value)
  end

  # ---- Keys: the same customer written two ways must give the same string ----

  def tagged(prefix, value) = ("#{prefix}:#{value}" if value.present?)
  def normalized_document(value) = value.to_s.upcase.delete("^A-Z0-9").presence
  def normalized_email(value) = value.to_s.strip.downcase.presence
  # The last 9 digits, so "+34 666 37 86 76" and "666378676" are the same phone
  def normalized_phone(value) = value.to_s.delete("^0-9").last(9).presence
  # ---- Values: each returns nil and adds a problem when the cell can't be read ----

  # 2026-10-14 or 14/10/2026
  def date(values, column, problems)
    value = values[column] or return
    [ "%Y-%m-%d", "%d/%m/%Y" ].each do |format|
      return Date.strptime(value, format)
    rescue Date::Error
      next
    end
    problems << problem(:date, column, value)
    nil
  end

  # 14.99 or 14,99
  def decimal(values, column, problems)
    value = values[column] or return
    return BigDecimal(value.tr(",", ".")) if value.match?(/\A-?\d+([.,]\d+)?\z/)
    problems << problem(:number, column, value)
    nil
  end

  def integer(values, column, problems)
    value = values[column] or return
    return value.to_i if value.match?(/\A-?\d+\z/)
    problems << problem(:number, column, value)
    nil
  end

  def boolean(values, column, problems)
    value = values[column] or return
    return true if YES.include?(value.downcase)
    return false if NO.include?(value.downcase)
    problems << problem(:boolean, column, value)
    nil
  end

  # Stored as "Male"/"Female", like the customer and pet forms
  def sex(values, problems)
    value = values["sex"] or return
    found = SEXES.find { |_sex, words| words.include?(value.downcase) }&.first
    problems << problem(:sex, "sex", value) unless found
    found
  end

  # Matched by name. A name that isn't there yet becomes a new category, saved together with the
  # first record that uses it (saving a record saves its new belongs_to parent first)
  def category(model, name)
    return if name.nil?
    @categories ||= model.where(enterprise: @enterprise).index_by { |category| category.name.to_s.downcase }
    @categories[name.downcase] ||= model.new(enterprise: @enterprise, name: name)
  end
end
