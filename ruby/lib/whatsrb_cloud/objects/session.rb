# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class Session
      attr_reader :id, :name, :status, :status_reason, :phone_number, :qr_code,
                  :connected, :last_connected_at, :created_at, :updated_at

      def initialize(data, client: nil)
        @id                = data['id']
        @name              = data['name']
        @status            = data['status']
        @status_reason     = data['status_reason']
        @phone_number      = data['phone_number']
        @qr_code           = data['qr_code']
        @connected         = data['connected']
        @last_connected_at = data['last_connected_at']
        @created_at        = data['created_at']
        @updated_at        = data['updated_at']
        @client       = client
        @raw          = data
      end

      def connected?
        @connected == true || @status == 'connected'
      end

      def send_message(to:, text:)
        messages_resource.create(to: to, text: text)
      end

      def send_image(to:, url:)
        messages_resource.create(to: to, message_type: 'image', content: url)
      end

      def send_document(to:, url:)
        messages_resource.create(to: to, message_type: 'document', content: url)
      end

      def send_video(to:, url:)
        messages_resource.create(to: to, message_type: 'video', content: url)
      end

      def send_audio(to:, url:)
        messages_resource.create(to: to, message_type: 'audio', content: url)
      end

      def send_location(to:, latitude:, longitude:)
        messages_resource.create(to: to, message_type: 'location', content: "#{latitude},#{longitude}")
      end

      def send_contact(to:, name:, phone:)
        messages_resource.create(to: to, message_type: 'contact', content: "#{name}:#{phone}")
      end

      def messages
        messages_resource
      end

      def reload
        refreshed = @client.sessions.retrieve(@id)
        @status            = refreshed.status
        @status_reason     = refreshed.status_reason
        @phone_number      = refreshed.phone_number
        @qr_code           = refreshed.qr_code
        @connected         = refreshed.connected
        @last_connected_at = refreshed.last_connected_at
        @name              = refreshed.name
        @updated_at        = refreshed.updated_at
        self
      end

      alias_method :refresh, :reload

      def wait_for_qr(timeout: 60, interval: 2, &block)
        deadline = Time.now + timeout

        loop do
          reload
          yield(@qr_code) if @status == 'qr_pending' && @qr_code && block
          return self if connected?
          raise WhatsrbCloud::Error, 'Timed out waiting for QR scan' if Time.now >= deadline

          sleep(interval)
        end
      end

      def to_h
        @raw
      end

      private

      def messages_resource
        @client.messages(@id)
      end
    end
  end
end
