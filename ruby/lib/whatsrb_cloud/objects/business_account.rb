# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class BusinessAccount
      attr_reader :id, :waba_id, :business_name, :display_name, :phone_number,
                  :phone_number_id, :status, :quality_rating, :connected,
                  :meta_token_expires_at

      def initialize(data, client: nil)
        @id              = data['id']
        @waba_id         = data['waba_id']
        @business_name   = data['business_name']
        @display_name    = data['display_name']
        @phone_number    = data['phone_number']
        @phone_number_id = data['phone_number_id']
        @status          = data['status']
        @quality_rating         = data['quality_rating']
        @connected              = data['connected']
        @meta_token_expires_at  = data['meta_token_expires_at']
        @client                 = client
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

      def send_image(to:, url:)
        messages_resource.create(to: to, message_type: 'image', content: url)
      end

      def send_video(to:, url:)
        messages_resource.create(to: to, message_type: 'video', content: url)
      end

      def send_audio(to:, url:)
        messages_resource.create(to: to, message_type: 'audio', content: url)
      end

      def send_document(to:, url:)
        messages_resource.create(to: to, message_type: 'document', content: url)
      end

      def send_buttons(to:, body:, buttons:)
        formatted = buttons.first(3).map.with_index do |btn, i|
          case btn
          when Hash then btn
          when String then { 'id' => "btn_#{i}", 'title' => btn }
          end
        end

        messages_resource.create(
          to: to,
          message_type: 'interactive',
          content: body,
          message_metadata: { buttons: formatted }
        )
      end

      def messages
        messages_resource
      end

      def window_open?(phone_number)
        result = @client.business_accounts.window(@id, phone_number: phone_number)
        result['open'] == true
      end

      def window(phone_number)
        @client.business_accounts.window(@id, phone_number: phone_number)
      end

      def templates
        @client.templates(@id)
      end

      def refresh
        refreshed = @client.business_accounts.retrieve(@id)
        @status        = refreshed.status
        @quality_rating = refreshed.quality_rating
        @connected              = refreshed.connected
        @meta_token_expires_at  = refreshed.meta_token_expires_at
        @display_name           = refreshed.display_name
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
