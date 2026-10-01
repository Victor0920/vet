module Webhooks
  class WhatsappController < ActionController::Base
    skip_forgery_protection
    before_action :verify_signature, only: :receive

    # GET — Meta's one-time subscription handshake
    def verify
      if params["hub.verify_token"] == Rails.application.credentials.dig(:whatsapp, :verify_token)
        render plain: params["hub.challenge"]
      else
        head :forbidden
      end
    end

    # POST — status updates and inbound messages
    def receive
      WhatsappWebhookJob.perform_later(params.to_unsafe_h)
      head :ok
    end


    private

    def verify_signature
      expected = "sha256=" + OpenSSL::HMAC.hexdigest(
        "SHA256",
        Rails.application.credentials.dig(:whatsapp, :app_secret),
        request.raw_post
      )

      unless ActiveSupport::SecurityUtils.secure_compare(
        expected, request.headers["X-Hub-Signature-256"].to_s
      )
        head :unauthorized
      end
    end
  end
end
