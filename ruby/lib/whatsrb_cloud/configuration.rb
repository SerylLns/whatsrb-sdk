# frozen_string_literal: true

module WhatsrbCloud
  class Configuration
    attr_accessor :api_key, :base_url, :timeout

    def initialize
      @api_key  = nil
      @base_url = 'https://api.whatsrb.com'
      @timeout  = 30
    end

    def inspect
      "#<#{self.class} base_url=#{@base_url.inspect} timeout=#{@timeout} api_key=[FILTERED]>"
    end
    alias to_s inspect
  end
end
