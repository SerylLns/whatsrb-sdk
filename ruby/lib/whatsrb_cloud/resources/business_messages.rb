# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class BusinessMessages
      VALID_TYPES = %w[text template image video audio document].freeze

      def initialize(connection:, account_id:)
        @connection = connection
        @account_id = account_id
      end

      def list(errors_only: false)
        path = base_path
        path += '?errors_only=true' if errors_only
        response = @connection.get(path)
        data = (response['data'] || []).map { |m| Objects::Message.new(m) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def retrieve(message_id)
        response = @connection.get("#{base_path}/#{message_id}")
        Objects::Message.new(response['data'])
      end

      def create(**params)
        validate_params!(params)
        body = build_message_body(params)
        response = @connection.post(base_path, { message: body })
        Objects::Message.new(response['data'])
      end

      private

      def base_path
        "/business_accounts/#{@account_id}/messages"
      end

      def validate_params!(params)
        validate_phone!(params[:to])
        msg_type = params[:message_type] || (params[:content] ? 'text' : nil)
        validate_type!(msg_type)
      end

      def validate_phone!(to)
        raise ValidationError, 'Phone number is required' if to.nil? || to.to_s.empty?
        raise ValidationError, 'Invalid phone number format' unless to.to_s.match?(/\A\+\d{1,15}\z/)
      end

      def validate_type!(msg_type)
        return unless msg_type && !VALID_TYPES.include?(msg_type)

        raise ValidationError, "Invalid message type: #{msg_type}"
      end

      def build_message_body(params)
        params.slice(:to, :message_type, :content, :template_name, :template_language)
      end
    end
  end
end
