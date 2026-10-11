# include AdminOnly in a controller to keep everyone but admins out
module AdminOnly
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
  end

  private

  def require_admin
    redirect_to root_path, alert: t("flash.not_authorized") unless Current.employee&.role == "admin"
  end
end
