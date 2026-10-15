# One CSV brought in from another program (or from our own export). Importing only ever adds:
# a row that matches something already there is skipped, never merged, so nothing gets overwritten.
#   1. created as "pending": the show page previews what each row would do (nothing saved yet)
#   2. run!: every new row is created in one transaction, then the file is deleted
class Import < ApplicationRecord
  # The file can't be read at all: not a CSV, a required column missing, too many rows…
  class Unreadable < StandardError; end

  KINDS = %w[ customers pets products services ].freeze
  MAX_SIZE = 5.megabytes
  MAX_ROWS = 5_000

  belongs_to :enterprise
  belongs_to :employee
  has_one_attached :file

  enum :status, { pending: "pending", completed: "completed" }, validate: true
  validates :kind, inclusion: { in: KINDS }
  validate :file_is_a_small_csv, on: :create

  # [Import::Base::Row, …]: what each row would do, worked out from the file and the database as they are now
  def rows
    @rows ||= importer.rows
  end

  # Creates every new row, all or nothing. Duplicates and rows with errors are skipped.
  # with_lock reloads the import first, so a double click on "Import" can't run it twice (false the second time)
  def run!
    ran = with_lock do
      return false unless pending?

      @rows = nil # work it out again, now: the database may have changed since the preview
      created = rows.select(&:new?).each { |row| row.record.save! }
      update!(status: :completed, completed_at: Time.current, created_count: created.size,
              duplicate_count: rows.count(&:duplicate?), error_count: rows.count(&:error?))
    end
    file.purge_later
    ran
  end

    private

  def importer
    { "customers" => Customers, "pets" => Pets, "products" => Products, "services" => Services }.fetch(kind).new(self)
  end

  def file_is_a_small_csv
    if !file.attached?
      errors.add(:file, :blank)
    elsif !file.filename.extension.to_s.casecmp?("csv")
      errors.add(:file, :csv_only)
    elsif file.byte_size > MAX_SIZE
      errors.add(:file, :too_big)
    end
  end
end
