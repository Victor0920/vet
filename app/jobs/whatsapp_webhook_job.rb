class WhatsappWebhookJob < ApplicationJob
  queue_as :default

  def perform(payload)
    Rails.logger.info "[WhatsApp webhook] #{payload.inspect}"
  end
end
