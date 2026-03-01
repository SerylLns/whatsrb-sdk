# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Connection do
  let(:connection) { described_class.new(api_key: 'wrb_live_test', base_url: 'https://api.whatsrb.com', timeout: 30) }

  describe 'auth headers' do
    it 'sends Authorization Bearer header' do
      stub = stub_request(:get, 'https://api.whatsrb.com/api/v1/test')
             .with(headers: { 'Authorization' => 'Bearer wrb_live_test' })
             .to_return(status: 200, body: '{"ok": true}', headers: { 'Content-Type' => 'application/json' })

      connection.get('/test')
      expect(stub).to have_been_requested
    end

    it 'sends User-Agent header' do
      stub = stub_request(:get, 'https://api.whatsrb.com/api/v1/test')
             .with(headers: { 'User-Agent' => "whatsrb-cloud-ruby/#{WhatsrbCloud::VERSION}" })
             .to_return(status: 200, body: '{"ok": true}', headers: { 'Content-Type' => 'application/json' })

      connection.get('/test')
      expect(stub).to have_been_requested
    end

    it 'sends Content-Type application/json' do
      stub = stub_request(:post, 'https://api.whatsrb.com/api/v1/test')
             .with(headers: { 'Content-Type' => 'application/json' })
             .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

      connection.post('/test', { key: 'value' })
      expect(stub).to have_been_requested
    end
  end

  describe 'JSON parsing' do
    it 'parses JSON response body' do
      FakeServer.stub_get('/test', response: { 'key' => 'value' })
      result = connection.get('/test')
      expect(result).to eq({ 'key' => 'value' })
    end

    it 'returns nil for empty response' do
      stub_request(:delete, 'https://api.whatsrb.com/api/v1/test')
        .to_return(status: 200, body: '', headers: {})

      result = connection.delete('/test')
      expect(result).to be_nil
    end
  end

  describe 'error mapping' do
    it 'raises AuthenticationError on 401' do
      FakeServer.stub_error(:get, '/fail', status: 401, body: { 'error' => 'Invalid API key' })
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::AuthenticationError, 'Invalid API key')
    end

    it 'raises ForbiddenError on 403' do
      FakeServer.stub_error(:get, '/fail', status: 403)
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::ForbiddenError)
    end

    it 'raises NotFoundError on 404' do
      FakeServer.stub_error(:get, '/fail', status: 404)
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::NotFoundError)
    end

    it 'raises ConflictError on 409' do
      FakeServer.stub_error(:get, '/fail', status: 409)
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::ConflictError)
    end

    it 'raises ValidationError on 422' do
      FakeServer.stub_error(:post, '/fail', status: 422, body: { 'error' => 'Name is required' })
      expect { connection.post('/fail') }.to raise_error(WhatsrbCloud::ValidationError, 'Name is required')
    end

    it 'raises RateLimitError on 429 with retry_after' do
      FakeServer.stub_error(:get, '/fail', status: 429, headers: { 'Retry-After' => '30' })
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::RateLimitError) do |error|
        expect(error.retry_after).to eq(30)
        expect(error.status).to eq(429)
      end
    end

    it 'raises ServerError on 500' do
      FakeServer.stub_error(:get, '/fail', status: 500)
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::ServerError)
    end

    it 'raises ServerError on 503' do
      FakeServer.stub_error(:get, '/fail', status: 503)
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::ServerError)
    end

    it 'raises base Error on unknown status' do
      FakeServer.stub_error(:get, '/fail', status: 418)
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::Error)
    end

    it 'exposes status and body on errors' do
      FakeServer.stub_error(:get, '/fail', status: 404, body: { 'error' => 'Not found' })
      expect { connection.get('/fail') }.to raise_error(WhatsrbCloud::NotFoundError) do |error|
        expect(error.status).to eq(404)
        expect(error.body).to eq({ 'error' => 'Not found' })
      end
    end
  end

  describe 'HTTP methods' do
    it 'sends POST with JSON body' do
      stub = stub_request(:post, 'https://api.whatsrb.com/api/v1/sessions')
             .with(body: '{"name":"Bot"}')
             .to_return(status: 200, body: '{"id":"sess_1"}', headers: { 'Content-Type' => 'application/json' })

      connection.post('/sessions', { name: 'Bot' })
      expect(stub).to have_been_requested
    end

    it 'sends PATCH with JSON body' do
      stub = stub_request(:patch, 'https://api.whatsrb.com/api/v1/webhooks/wh_1')
             .with(body: '{"url":"https://new.example.com"}')
             .to_return(status: 200, body: '{"id":"wh_1"}', headers: { 'Content-Type' => 'application/json' })

      connection.patch('/webhooks/wh_1', { url: 'https://new.example.com' })
      expect(stub).to have_been_requested
    end

    it 'sends DELETE' do
      stub = stub_request(:delete, 'https://api.whatsrb.com/api/v1/sessions/sess_1')
             .to_return(status: 200, body: '', headers: {})

      connection.delete('/sessions/sess_1')
      expect(stub).to have_been_requested
    end
  end
end
