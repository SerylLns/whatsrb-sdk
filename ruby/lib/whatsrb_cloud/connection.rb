# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module WhatsrbCloud
  class Connection
    API_PREFIX = '/api/v1'

    def initialize(api_key:, base_url:, timeout:)
      @api_key  = api_key
      @base_url = base_url
      @timeout  = timeout
    end

    def inspect
      "#<#{self.class} base_url=#{@base_url.inspect} api_key=[FILTERED]>"
    end
    alias to_s inspect

    def get(path)
      request(Net::HTTP::Get, path)
    end

    def post(path, body = {})
      request(Net::HTTP::Post, path, body)
    end

    def patch(path, body = {})
      request(Net::HTTP::Patch, path, body)
    end

    def delete(path)
      request(Net::HTTP::Delete, path)
    end

    private

    def request(method_class, path, body = nil)
      uri = URI("#{@base_url}#{API_PREFIX}#{path}")
      http = build_http(uri)
      req = build_request(method_class, uri, body)
      response = http.request(req)
      handle_response(response)
    end

    def build_http(uri)
      unless uri.scheme == 'https' || uri.host == 'localhost' || uri.host == '127.0.0.1'
        raise ArgumentError, "Only HTTPS connections are allowed (got #{uri.scheme}://#{uri.host})"
      end

      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      http.open_timeout = @timeout
      http.read_timeout = @timeout
      http
    end

    def build_request(method_class, uri, body)
      req = method_class.new(uri.request_uri)
      req['Authorization'] = "Bearer #{@api_key}"
      req['Content-Type']  = 'application/json'
      req['Accept']        = 'application/json'
      req['User-Agent']    = "whatsrb-cloud-ruby/#{WhatsrbCloud::VERSION}"
      req.body = JSON.generate(body) if body
      req
    end

    def handle_response(response)
      body = parse_body(response.body)
      return body if response.is_a?(Net::HTTPSuccess)

      raise_error(response.code.to_i, body, response)
    end

    def parse_body(raw)
      return nil if raw.nil? || raw.empty?

      JSON.parse(raw)
    rescue JSON::ParserError
      nil
    end

    def raise_error(status, body, response) # rubocop:disable Metrics/CyclomaticComplexity
      message = error_message(body)

      case status
      when 401
        raise AuthenticationError.new(message, status: status, body: body)
      when 403
        raise ForbiddenError.new(message, status: status, body: body)
      when 404
        raise NotFoundError.new(message, status: status, body: body)
      when 409
        raise ConflictError.new(message, status: status, body: body)
      when 422
        raise ValidationError.new(message, status: status, body: body)
      when 429
        retry_after = response['Retry-After']&.to_i
        raise RateLimitError.new(message, status: status, body: body, retry_after: retry_after)
      when 500..599
        raise ServerError.new(message, status: status, body: body)
      else
        raise Error.new(message, status: status, body: body)
      end
    end

    def error_message(body)
      return 'Unknown error' unless body.is_a?(Hash)

      body['error'] || body['message'] || 'Unknown error'
    end
  end
end
