# Records which employee last changed the record, alongside Rails' updated_at.
module TracksUpdatedBy
  extend ActiveSupport::Concern

  included do
    belongs_to :updated_by, class_name: "Employee", optional: true
    # Only when something actually changed, the same rule Rails uses for updated_at
    before_save :set_updated_by, if: :has_changes_to_save?
  end

  private

  # nil outside a request (console, seeds): better blank than crediting the wrong person
  def set_updated_by
    self.updated_by = Current.employee
  end
end
