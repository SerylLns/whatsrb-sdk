# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class Messages
      def initialize(connection:, session_id:)
        @connection = connection
        @session_id = session_id
      end

      def list
        response = @connection.get("/sessions/#{@session_id}/messages")
        data = (response['data'] || []).map { |m| Objects::Message.new(m) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def retrieve(message_id)
        response = @connection.get("/sessions/#{@session_id}/messages/#{message_id}")
        Objects::Message.new(response['data'])
      end

      VALID_TYPES = %w[text image video audio document location contact].freeze

      def create(**params)
        validate_params!(params)
        body = build_message_body(params)
        response = @connection.post("/sessions/#{@session_id}/messages", { message: body })
        Objects::Message.new(response['data'])
      end

      private

      def validate_params!(params)
        validate_phone!(params[:to])
        validate_type!(params[:message_type] || (params[:text] ? 'text' : nil))
      end

      def validate_phone!(to)
        raise ValidationError, 'Phone number is required' if to.nil? || to.empty?
        raise ValidationError, 'Invalid phone number format' unless to.match?(/\A\+\d{1,15}\z/)
      end

      def validate_type!(msg_type)
        return unless msg_type && !VALID_TYPES.include?(msg_type)

        raise ValidationError, "Invalid message type: #{msg_type}"
      end

      def build_message_body(params)
        if params[:text]
          { to: params[:to], message_type: 'text', content: params[:text] }
        else
          params.slice(:to, :message_type, :content)
        end
      end
    end
  end
end
