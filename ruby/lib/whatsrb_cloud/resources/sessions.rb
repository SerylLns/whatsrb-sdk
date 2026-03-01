# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class Sessions
      def initialize(client:, connection:)
        @client     = client
        @connection = connection
      end

      def list
        response = @connection.get('/sessions')
        data = (response['data'] || []).map { |s| Objects::Session.new(s, client: @client) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def create(**params)
        response = @connection.post('/sessions', { session: params })
        Objects::Session.new(response['data'], client: @client)
      end

      def retrieve(id)
        response = @connection.get("/sessions/#{id}")
        Objects::Session.new(response['data'], client: @client)
      end

      def delete(id)
        @connection.delete("/sessions/#{id}")
        true
      end
    end
  end
end
