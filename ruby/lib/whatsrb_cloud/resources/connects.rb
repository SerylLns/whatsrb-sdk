# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class Connects
      def initialize(client:, connection:)
        @client     = client
        @connection = connection
      end

      def retrieve(id)
        response = @connection.get("/connects/#{id}")
        Objects::ConnectRequest.new(response['data'], client: @client)
      end
    end
  end
end
