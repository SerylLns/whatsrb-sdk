# frozen_string_literal: true

module WhatsrbCloud
  class Client
    attr_reader :connection

    def inspect
      "#<#{self.class} base_url=#{@base_url.inspect} api_key=[FILTERED]>"
    end
    alias to_s inspect

    def initialize(api_key: nil, base_url: nil, timeout: nil)
      config = WhatsrbCloud.configuration
      @api_key  = api_key  || config.api_key || raise(AuthenticationError, 'API key is required')
      @base_url = base_url || config.base_url
      @timeout  = timeout  || config.timeout

      @connection = Connection.new(api_key: @api_key, base_url: @base_url, timeout: @timeout)
    end

    def sessions
      Resources::Sessions.new(client: self, connection: @connection)
    end

    def messages(session_id)
      Resources::Messages.new(connection: @connection, session_id: session_id)
    end

    def webhooks
      Resources::Webhooks.new(connection: @connection)
    end

    def usage
      Resources::Usage.new(connection: @connection).fetch
    end

    def business_accounts
      Resources::BusinessAccounts.new(client: self, connection: @connection)
    end

    def connects
      Resources::Connects.new(client: self, connection: @connection)
    end

    def business_messages(account_id)
      Resources::BusinessMessages.new(connection: @connection, account_id: account_id)
    end

    def templates(account_id)
      Resources::Templates.new(connection: @connection, account_id: account_id)
    end
  end
end
