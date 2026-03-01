# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class BusinessAccount
      attr_reader :id, :waba_id, :business_name, :display_name, :phone_number,
                  :phone_number_id, :status, :quality_rating, :connected

      def initialize(data, client: nil)
        @id              = data['id']
        @waba_id         = data['waba_id']
        @business_name   = data['business_name']
        @display_name    = data['display_name']
        @phone_number    = data['phone_number']
        @phone_number_id = data['phone_number_id']
        @status          = data['status']
        @quality_rating  = data['quality_rating']
        @connected       = data['connected']
        @client          = client
        @raw             = data
      end

      def connected?
        @connected == true || @status == 'connected'
      end

      def send_text(to:, text:)
        messages_resource.create(to: to, message_type: 'text', content: text)
      end

      def send_template(to:, template_name:, template_language:)
        messages_resource.create(
          to: to,
          message_type: 'template',
          template_name: template_name,
          template_language: template_language
        )
      end

      def messages
        messages_resource
      end

      def templates
        @client.templates(@id)
      end

      def refresh
        refreshed = @client.business_accounts.retrieve(@id)
        @status        = refreshed.status
        @quality_rating = refreshed.quality_rating
        @connected     = refreshed.connected
        @display_name  = refreshed.display_name
        @phone_number  = refreshed.phone_number
        self
      end

      alias_method :reload, :refresh

      def to_h
        @raw
      end

      private

      def messages_resource
        @client.business_messages(@id)
      end
    end
  end
end
