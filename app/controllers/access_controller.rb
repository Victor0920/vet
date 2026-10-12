class AccessController < ApplicationController
  include AdminOnly

  before_action :set_enterprise, only: %i[ show edit update ]

  def show
  end

  def edit
  end

  def update
    if @enterprise.update(enterprise_params)
      redirect_to access_path, notice: t("flash.access.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_enterprise
    @enterprise = Current.enterprise
  end

  def enterprise_params
    params.expect(enterprise: [ :login_code ])
  end
end
