class ImportsController < ApplicationController
  include AdminOnly
  before_action :set_import, only: %i[ show destroy ]
  rate_limit to: 20, within: 1.hour, only: :create,
    with: -> { redirect_to imports_path, alert: t("flash.imports.rate_limited") }

  def index
    @imports = Current.enterprise.imports.includes(:employee).order(created_at: :desc)
  end

  # ?kind=pets preselects the type (links from the index)
  def new
    @import = Import.new(kind: params[:kind].presence_in(Import::KINDS) || "customers")
  end

  def create
    @import = Current.enterprise.imports.new(import_params.merge(employee: Current.employee))

    if @import.save
      redirect_to import_path(@import)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Pending: the preview. Completed: what was imported (the file is gone by then)
  def show
    @rows = @import.rows if @import.pending?
  rescue Import::Unreadable => error
    @unreadable = error.message
  end

  # Discards an import that was never confirmed (nothing was imported, so nothing to undo)
  def destroy
    @import.destroy if @import.pending?
    redirect_to imports_path, notice: t("flash.imports.discarded")
  end

  private

  def set_import
    @import = Current.enterprise.imports.find_by(id: params[:id])
    redirect_to imports_path, alert: t("flash.imports.not_found") if @import.nil?
  end

  def import_params
    params.expect(import: [ :kind, :file ])
  end
end
