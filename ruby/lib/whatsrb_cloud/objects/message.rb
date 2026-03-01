# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class Message
      attr_reader :id, :session_id, :business_account_id, :to, :status,
                  :message_type, :content, :direction, :whatsapp_message_id,
                  :wamid, :error_message, :template_name, :template_language,
                  :sent_at, :delivered_at, :read_at, :created_at

      def initialize(data)
        @id                   = data['id']
        @session_id           = data['session_id']
        @business_account_id  = data['business_account_id']
        @to                   = data['to']
        @status               = data['status']
        @message_type         = data['message_type']
        @content              = data['content']
        @direction            = data['direction']
        @whatsapp_message_id  = data['whatsapp_message_id']
        @wamid                = data['wamid']
        @error_message        = data['error_message']
        @template_name        = data['template_name']
        @template_language    = data['template_language']
        @sent_at              = parse_time(data['sent_at'])
        @delivered_at         = parse_time(data['delivered_at'])
        @read_at              = parse_time(data['read_at'])
        @created_at           = parse_time(data['created_at'])
      end

      def queued?    = @status == 'queued'
      def sent?      = @status == 'sent'
      def delivered? = @status == 'delivered'
      def read?      = @status == 'read'
      def failed?    = @status == 'failed'

      def to_h
        {
          'id' => @id, 'session_id' => @session_id, 'to' => @to,
          'status' => @status, 'message_type' => @message_type, 'content' => @content
        }
      end

      private

      def parse_time(value)
        return nil if value.nil?

        Time.parse(value)
      rescue ArgumentError
        nil
      end
    end
  end
end
