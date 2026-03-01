# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class Usage
      def initialize(connection:)
        @connection = connection
      end

      def fetch
        response = @connection.get('/usage')
        response['data']
      end
    end
  end
end
