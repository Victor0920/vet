# include AdminOnly in a controller to keep everyone but admins out
# (require_admin lives in ApplicationController)
module AdminOnly
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
  end
end
