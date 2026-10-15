# "Import": creates the rows the preview showed as new
class Imports::RunsController < ApplicationController
  include AdminOnly

  def create
    import = Current.enterprise.imports.find_by(id: params[:import_id])
    return redirect_to imports_path, alert: t("flash.imports.not_found") if import.nil?

    if import.run!
      redirect_to import_path(import), notice: t("flash.imports.completed", count: import.created_count)
    else
      redirect_to import_path(import) # already ran (double click)
    end
  rescue ActiveRecord::RecordInvalid, Import::Unreadable
    redirect_to import_path(import), alert: t("flash.imports.failed")
  end
end
