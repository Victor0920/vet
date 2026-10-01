module Whatsapp
  class Client
    class DeliveryError < StandardError; end

    BASE_URL = "https://graph.facebook.com/v21.0".freeze


    def initialize(
      phone_number_id: Rails.application.credentials.dig(:whatsapp, :phone_number_id),
      access_token: Rails.application.credentials.dig(:whatsapp, :access_token)
    )
      @phone_number_id = phone_number_id
      @access_token = access_token
    end


    def send_text(to:, body:)
      uri = URI("#{BASE_URL}/#{@phone_number_id}/messages")

      response = Net::HTTP.post(
        uri,
        {
          messaging_product: "whatsapp",
          to: to,
          type: "text",
          text: { body: body }
        }.to_json,
        "Authorization" => "Bearer #{@access_token}",
        "Content-Type" => "application/json"
      )

      unless response.is_a?(Net::HTTPSuccess)
        raise DeliveryError, "WhatsApp returned #{response.code}: #{response.body}"
      end

      JSON.parse(response.body)
    end
  end
end
