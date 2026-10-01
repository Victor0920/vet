class WhatsappNotificationJob < ApplicationJob
  queue_as :default

  retry_on Whatsapp::Client::DeliveryError, wait: :polynomially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(message_id)
    message = Message.find(message_id)

    Whatsapp::Client.new.send_text(
      to: message.conversation.user.phone,
      body: message.text
    )
  end
end
