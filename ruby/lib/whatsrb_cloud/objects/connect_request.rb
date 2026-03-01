# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class ConnectRequest
      attr_reader :id, :url, :status, :expires_at, :account, :error

      def initialize(data, client: nil)
        @id         = data['id']
        @url        = data['url']
        @status     = data['status']
        @expires_at = data['expires_at']
        @error      = data['error']
        @client     = client
        @raw        = data

        if data['account']
          @account = Objects::BusinessAccount.new(data['account'], client: client)
        end
      end

      def pending?
        @status == 'pending'
      end

      def completed?
        @status == 'completed'
      end

      def expired?
        @status == 'expired'
      end

      def failed?
        @status == 'failed'
      end

      def reload
        refreshed = @client.connects.retrieve(@id)
        @status     = refreshed.status
        @account    = refreshed.account
        @error      = refreshed.error
        @expires_at = refreshed.expires_at
        self
      end

      alias_method :refresh, :reload

      def wait_for_account(timeout: 300, interval: 2)
        deadline = Time.now + timeout

        loop do
          reload
          return @account if completed? && @account
          raise WhatsrbCloud::Error, "Connect request expired" if expired?
          raise WhatsrbCloud::Error, "Connect request failed: #{@error}" if failed?
          raise WhatsrbCloud::Error, "Timed out waiting for account connection" if Time.now >= deadline

          sleep(interval)
        end
      end

      def to_h
        @raw
      end
    end
  end
end
