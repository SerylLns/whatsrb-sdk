# frozen_string_literal: true

module FakeServer
  extend WebMock::API

  BASE = 'https://api.whatsrb.com/api/v1'

  module_function

  def stub_get(path, response:, status: 200)
    stub_request(:get, "#{BASE}#{path}")
      .to_return(status: status, body: JSON.generate(response), headers: json_headers)
  end

  def stub_post(path, response:, status: 200)
    stub_request(:post, "#{BASE}#{path}")
      .to_return(status: status, body: JSON.generate(response), headers: json_headers)
  end

  def stub_patch(path, response:, status: 200)
    stub_request(:patch, "#{BASE}#{path}")
      .to_return(status: status, body: JSON.generate(response), headers: json_headers)
  end

  def stub_delete(path, status: 200)
    stub_request(:delete, "#{BASE}#{path}")
      .to_return(status: status, body: nil, headers: json_headers)
  end

  def stub_error(method, path, status:, body: { 'error' => 'Error' }, headers: {})
    stub_request(method, "#{BASE}#{path}")
      .to_return(status: status, body: JSON.generate(body), headers: json_headers.merge(headers))
  end

  def json_headers
    { 'Content-Type' => 'application/json' }
  end
end
