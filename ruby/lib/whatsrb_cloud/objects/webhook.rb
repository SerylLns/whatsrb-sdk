# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class Webhook
      attr_reader :id, :url, :events, :secret, :created_at, :updated_at

      def initialize(data)
        @id         = data['id']
        @url        = data['url']
        @events     = data['events'] || []
        @active     = data.fetch('active', true)
        @secret     = data['secret']
        @created_at = data['created_at']
        @updated_at = data['updated_at']
      end

      def active?
        @active
      end

      def to_h
        { 'id' => @id, 'url' => @url, 'events' => @events, 'active' => @active }
      end
    end
  end
end
