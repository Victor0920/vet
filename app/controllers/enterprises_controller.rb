class EnterprisesController < ApplicationController
  before_action :set_enterprise, only: %i[ show edit update ]

  def show
  end

  def edit
  end

  def update
    if @enterprise.update(enterprise_params)
      redirect_to enterprise_path(), notice: t("flash.enterprise.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_enterprise
    @enterprise = Current.enterprise
  end

  def enterprise_params
    params.expect(enterprise: [ :name, :legal_name, :cif, :address ])
  end
end
