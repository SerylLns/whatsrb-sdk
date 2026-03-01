# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class Webhooks
      def initialize(connection:)
        @connection = connection
      end

      def list
        response = @connection.get('/webhooks')
        data = (response['data'] || []).map { |w| Objects::Webhook.new(w) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def create(**params)
        response = @connection.post('/webhooks', { webhook: params })
        Objects::Webhook.new(response['data'])
      end

      def retrieve(id)
        response = @connection.get("/webhooks/#{id}")
        Objects::Webhook.new(response['data'])
      end

      def update(id, **params)
        response = @connection.patch("/webhooks/#{id}", { webhook: params })
        Objects::Webhook.new(response['data'])
      end

      def delete(id)
        @connection.delete("/webhooks/#{id}")
        true
      end
    end
  end
end
