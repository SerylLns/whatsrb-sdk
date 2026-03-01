# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class BusinessAccounts
      def initialize(client:, connection:)
        @client     = client
        @connection = connection
      end

      def list
        response = @connection.get('/business_accounts')
        data = (response['data'] || []).map { |a| Objects::BusinessAccount.new(a, client: @client) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def retrieve(id)
        response = @connection.get("/business_accounts/#{id}")
        Objects::BusinessAccount.new(response['data'], client: @client)
      end

      def connect
        response = @connection.post('/business_accounts/connect')
        Objects::ConnectRequest.new(response['data'], client: @client)
      end

      def connect_manual(**params)
        response = @connection.post('/business_accounts', { business_account: params })
        Objects::BusinessAccount.new(response['data'], client: @client)
      end

      alias_method :create, :connect_manual

      def delete(id)
        @connection.delete("/business_accounts/#{id}")
        true
      end
    end
  end
end
