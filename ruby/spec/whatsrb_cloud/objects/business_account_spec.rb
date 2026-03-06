# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Objects::BusinessAccount do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  let(:account_data) do
    {
      'id' => 'ba_1', 'waba_id' => 'waba_123', 'business_name' => 'Acme',
      'display_name' => 'Acme Support', 'phone_number' => '+33612345678',
      'phone_number_id' => 'pn_abc', 'status' => 'connected',
      'quality_rating' => 'GREEN', 'connected' => true,
      'meta_token_expires_at' => '2025-06-01T00:00:00Z'
    }
  end

  let(:account) { described_class.new(account_data, client: client) }

  describe '#connected?' do
    it 'returns true when connected is true' do
      expect(account).to be_connected
    end

    it 'returns false when not connected' do
      acc = described_class.new(account_data.merge('connected' => false, 'status' => 'disconnected'), client: client)
      expect(acc).not_to be_connected
    end
  end

  describe '#send_text' do
    it 'creates a text message via business_messages resource' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"text","content":"Hello!"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_1","to":"+33600000001","message_type":"text","content":"Hello!"}}',
                        headers: FakeServer.json_headers)

      msg = account.send_text(to: '+33600000001', text: 'Hello!')
      expect(msg).to be_a(WhatsrbCloud::Objects::Message)
      expect(stub).to have_been_requested
    end
  end

  describe '#send_template' do
    it 'creates a template message via business_messages resource' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"template","template_name":"hello_world","template_language":"en"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_2","message_type":"template"}}',
                        headers: FakeServer.json_headers)

      msg = account.send_template(to: '+33600000001', template_name: 'hello_world', template_language: 'en')
      expect(msg).to be_a(WhatsrbCloud::Objects::Message)
      expect(stub).to have_been_requested
    end
  end

  describe '#send_image' do
    it 'creates an image message' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"image","content":"https://example.com/photo.jpg"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_3","message_type":"image"}}',
                        headers: FakeServer.json_headers)

      msg = account.send_image(to: '+33600000001', url: 'https://example.com/photo.jpg')
      expect(msg).to be_a(WhatsrbCloud::Objects::Message)
      expect(stub).to have_been_requested
    end
  end

  describe '#send_video' do
    it 'creates a video message' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"video","content":"https://example.com/video.mp4"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_4","message_type":"video"}}',
                        headers: FakeServer.json_headers)

      account.send_video(to: '+33600000001', url: 'https://example.com/video.mp4')
      expect(stub).to have_been_requested
    end
  end

  describe '#send_audio' do
    it 'creates an audio message' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"audio","content":"https://example.com/audio.ogg"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_5","message_type":"audio"}}',
                        headers: FakeServer.json_headers)

      account.send_audio(to: '+33600000001', url: 'https://example.com/audio.ogg')
      expect(stub).to have_been_requested
    end
  end

  describe '#send_document' do
    it 'creates a document message' do
      stub = stub_request(:post, "#{FakeServer::BASE}/business_accounts/ba_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"document","content":"https://example.com/doc.pdf"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_6","message_type":"document"}}',
                        headers: FakeServer.json_headers)

      account.send_document(to: '+33600000001', url: 'https://example.com/doc.pdf')
      expect(stub).to have_been_requested
    end
  end

  describe '#window_open?' do
    it 'returns true when window is open' do
      stub_request(:get, "#{FakeServer::BASE}/business_accounts/ba_1/window?phone_number=%2B33600000001")
        .to_return(status: 200,
                   body: '{"data":{"phone_number":"+33600000001","open":true,"last_inbound_at":"2026-03-06T10:00:00Z","expires_at":"2026-03-07T10:00:00Z"}}',
                   headers: FakeServer.json_headers)

      expect(account.window_open?('+33600000001')).to be(true)
    end

    it 'returns false when window is closed' do
      stub_request(:get, "#{FakeServer::BASE}/business_accounts/ba_1/window?phone_number=%2B33600000001")
        .to_return(status: 200,
                   body: '{"data":{"phone_number":"+33600000001","open":false,"last_inbound_at":null,"expires_at":null}}',
                   headers: FakeServer.json_headers)

      expect(account.window_open?('+33600000001')).to be(false)
    end
  end

  describe '#window' do
    it 'returns full window data' do
      stub_request(:get, "#{FakeServer::BASE}/business_accounts/ba_1/window?phone_number=%2B33600000001")
        .to_return(status: 200,
                   body: '{"data":{"phone_number":"+33600000001","open":true,"last_inbound_at":"2026-03-06T10:00:00Z","expires_at":"2026-03-07T10:00:00Z"}}',
                   headers: FakeServer.json_headers)

      result = account.window('+33600000001')
      expect(result['open']).to be(true)
      expect(result['expires_at']).to eq('2026-03-07T10:00:00Z')
    end
  end

  describe '#meta_token_expires_at' do
    it 'returns the token expiration' do
      expect(account.meta_token_expires_at).to eq('2025-06-01T00:00:00Z')
    end
  end

  describe '#messages' do
    it 'returns a BusinessMessages resource scoped to the account' do
      expect(account.messages).to be_a(WhatsrbCloud::Resources::BusinessMessages)
    end
  end

  describe '#templates' do
    it 'returns a Templates resource scoped to the account' do
      expect(account.templates).to be_a(WhatsrbCloud::Resources::Templates)
    end
  end

  describe '#refresh' do
    it 're-fetches account data from the API' do
      FakeServer.stub_get('/business_accounts/ba_1', response: {
                            'data' => account_data.merge('status' => 'disconnected', 'connected' => false)
                          })

      account.refresh
      expect(account.status).to eq('disconnected')
      expect(account).not_to be_connected
    end
  end

  describe '#to_h' do
    it 'returns the raw data hash' do
      expect(account.to_h).to eq(account_data)
    end
  end
end
