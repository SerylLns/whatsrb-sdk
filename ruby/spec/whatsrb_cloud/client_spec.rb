# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Client do
  describe '#initialize' do
    it 'uses provided api_key' do
      client = described_class.new(api_key: 'wrb_live_test')
      expect(client.connection).to be_a(WhatsrbCloud::Connection)
    end

    it 'uses configured api_key' do
      WhatsrbCloud.configure { |c| c.api_key = 'wrb_live_configured' }
      client = described_class.new
      expect(client.connection).to be_a(WhatsrbCloud::Connection)
    end

    it 'raises AuthenticationError without api_key' do
      expect { described_class.new }.to raise_error(WhatsrbCloud::AuthenticationError, 'API key is required')
    end

    it 'allows overriding base_url and timeout' do
      client = described_class.new(api_key: 'wrb_live_test', base_url: 'http://localhost:3000', timeout: 5)
      expect(client).to be_a(described_class)
    end
  end

  describe 'resource accessors' do
    let(:client) { described_class.new(api_key: 'wrb_live_test') }

    it 'returns Sessions resource' do
      expect(client.sessions).to be_a(WhatsrbCloud::Resources::Sessions)
    end

    it 'returns Messages resource scoped to session' do
      expect(client.messages('sess_abc')).to be_a(WhatsrbCloud::Resources::Messages)
    end

    it 'returns Webhooks resource' do
      expect(client.webhooks).to be_a(WhatsrbCloud::Resources::Webhooks)
    end

    it 'fetches usage unwrapped from data key' do
      FakeServer.stub_get('/usage', response: {
                            'data' => { 'plan' => 'free', 'sessions' => { 'used' => 1, 'limit' => 1 } }
                          })
      result = client.usage
      expect(result['plan']).to eq('free')
    end

    it 'returns BusinessAccounts resource' do
      expect(client.business_accounts).to be_a(WhatsrbCloud::Resources::BusinessAccounts)
    end

    it 'returns BusinessMessages resource scoped to account' do
      expect(client.business_messages('ba_abc')).to be_a(WhatsrbCloud::Resources::BusinessMessages)
    end

    it 'returns Templates resource scoped to account' do
      expect(client.templates('ba_abc')).to be_a(WhatsrbCloud::Resources::Templates)
    end
  end
end
