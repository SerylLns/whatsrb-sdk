# frozen_string_literal: true

require 'openssl'

module WhatsrbCloud
  module WebhookSignature
    PREFIX = 'sha256='
    # Maximum age of a webhook signature before it's considered stale (5 minutes)
    TOLERANCE = 300

    module_function

    # Verify a webhook signature.
    #
    # @param payload [String] raw request body
    # @param secret [String] webhook secret (whsec_...)
    # @param signature [String] value of X-Webhook-Signature header
    # @param timestamp [String, nil] value of X-Webhook-Timestamp header (epoch seconds)
    # @param tolerance [Integer] max age in seconds (default 300)
    # @return [Boolean]
    def verify?(payload:, secret:, signature:, timestamp: nil, tolerance: TOLERANCE)
      return false if payload.nil? || secret.nil? || signature.nil?
      return false unless signature.start_with?(PREFIX)
      return false if stale_timestamp?(timestamp, tolerance)

      expected = "#{PREFIX}#{OpenSSL::HMAC.hexdigest('SHA256', secret, payload)}"
      secure_compare(expected, signature)
    end

    def stale_timestamp?(timestamp, tolerance)
      return false unless timestamp

      ts = Integer(timestamp, exception: false)
      return true unless ts

      (Time.now.to_i - ts).abs > tolerance
    end

    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      OpenSSL.fixed_length_secure_compare(a, b)
    end

    private_class_method :secure_compare
  end
end
