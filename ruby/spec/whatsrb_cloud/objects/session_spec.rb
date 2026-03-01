# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Objects::Session do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  let(:session_data) do
    {
      'id' => 'sess_1', 'name' => 'Bot', 'status' => 'connected',
      'phone_number' => '+33612345678', 'qr_code' => nil
    }
  end

  let(:session) { described_class.new(session_data, client: client) }

  describe '#connected?' do
    it 'returns true when status is connected' do
      expect(session).to be_connected
    end

    it 'returns false when status is not connected' do
      session = described_class.new(session_data.merge('status' => 'disconnected'), client: client)
      expect(session).not_to be_connected
    end
  end

  describe '#send_message' do
    it 'delegates to messages resource with text shorthand' do
      stub = stub_request(:post, "#{FakeServer::BASE}/sessions/sess_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"text","content":"Hello!"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_1","to":"+33600000001","message_type":"text"}}',
                        headers: FakeServer.json_headers)

      msg = session.send_message(to: '+33600000001', text: 'Hello!')
      expect(msg).to be_a(WhatsrbCloud::Objects::Message)
      expect(stub).to have_been_requested
    end
  end

  describe '#send_image' do
    it 'sends image URL as content' do
      stub = stub_request(:post, "#{FakeServer::BASE}/sessions/sess_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"image","content":"https://img.example.com/photo.jpg"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_2","message_type":"image"}}',
                        headers: FakeServer.json_headers)

      session.send_image(to: '+33600000001', url: 'https://img.example.com/photo.jpg')
      expect(stub).to have_been_requested
    end
  end

  describe '#send_location' do
    it 'sends location as serialized content' do
      stub = stub_request(:post, "#{FakeServer::BASE}/sessions/sess_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"location","content":"48.8,2.3"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_3","message_type":"location"}}',
                        headers: FakeServer.json_headers)

      session.send_location(to: '+33600000001', latitude: 48.8, longitude: 2.3)
      expect(stub).to have_been_requested
    end
  end

  describe '#send_contact' do
    it 'sends contact as serialized content' do
      stub = stub_request(:post, "#{FakeServer::BASE}/sessions/sess_1/messages")
             .with(body: '{"message":{"to":"+33600000001","message_type":"contact","content":"John:+33600000002"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"msg_4","message_type":"contact"}}',
                        headers: FakeServer.json_headers)

      session.send_contact(to: '+33600000001', name: 'John', phone: '+33600000002')
      expect(stub).to have_been_requested
    end
  end

  describe '#reload' do
    it 're-fetches session data from the API' do
      FakeServer.stub_get('/sessions/sess_1', response: {
                            'data' => {
                              'id' => 'sess_1', 'name' => 'Bot Updated', 'status' => 'disconnected',
                              'phone_number' => '+33612345678', 'qr_code' => nil
                            }
                          })

      session.reload
      expect(session.name).to eq('Bot Updated')
      expect(session.status).to eq('disconnected')
      expect(session).not_to be_connected
    end
  end

  describe '#wait_for_qr' do
    it 'polls until connected' do
      call_count = 0
      stub_request(:get, "#{FakeServer::BASE}/sessions/sess_1")
        .to_return do
          call_count += 1
          body = if call_count < 3
                   { 'data' => { 'id' => 'sess_1', 'status' => 'qr_pending', 'qr_code' => 'base64data' } }
                 else
                   { 'data' => { 'id' => 'sess_1', 'status' => 'connected', 'qr_code' => nil } }
                 end
          { status: 200, body: JSON.generate(body), headers: FakeServer.json_headers }
        end

      qr_codes = []
      disconnected_session = described_class.new(session_data.merge('status' => 'qr_pending'), client: client)

      result = disconnected_session.wait_for_qr(timeout: 10, interval: 0.01) { |qr| qr_codes << qr }

      expect(result).to be_connected
      expect(qr_codes).to eq(%w[base64data base64data])
    end

    it 'raises on timeout' do
      stub_request(:get, "#{FakeServer::BASE}/sessions/sess_1")
        .to_return do
          body = { 'data' => { 'id' => 'sess_1', 'status' => 'qr_pending', 'qr_code' => 'data' } }
          { status: 200, body: JSON.generate(body), headers: FakeServer.json_headers }
        end

      disconnected_session = described_class.new(session_data.merge('status' => 'qr_pending'), client: client)

      expect do
        disconnected_session.wait_for_qr(timeout: 0.05, interval: 0.01) { |_qr| nil }
      end.to raise_error(WhatsrbCloud::Error, 'Timed out waiting for QR scan')
    end
  end

  describe '#messages' do
    it 'returns a Messages resource scoped to the session' do
      expect(session.messages).to be_a(WhatsrbCloud::Resources::Messages)
    end
  end

  describe '#to_h' do
    it 'returns the raw data hash' do
      expect(session.to_h).to eq(session_data)
    end
  end
end
