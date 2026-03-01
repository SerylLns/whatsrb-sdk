# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Objects::BusinessAccount do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  let(:account_data) do
    {
      'id' => 'ba_1', 'waba_id' => 'waba_123', 'business_name' => 'Acme',
      'display_name' => 'Acme Support', 'phone_number' => '+33612345678',
      'phone_number_id' => 'pn_abc', 'status' => 'connected',
      'quality_rating' => 'GREEN', 'connected' => true
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
