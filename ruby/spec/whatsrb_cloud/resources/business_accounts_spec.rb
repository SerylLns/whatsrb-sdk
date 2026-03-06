# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::BusinessAccounts do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }
  let(:resource) { client.business_accounts }

  describe '#list' do
    it 'returns a List of BusinessAccount objects' do
      FakeServer.stub_get('/business_accounts', response: {
                            'data' => [
                              { 'id' => 'ba_1', 'business_name' => 'Acme', 'status' => 'connected' },
                              { 'id' => 'ba_2', 'business_name' => 'Beta', 'status' => 'disconnected' }
                            ],
                            'meta' => { 'total' => 2 }
                          })

      list = resource.list
      expect(list).to be_a(WhatsrbCloud::Objects::List)
      expect(list.data.size).to eq(2)
      expect(list.data.first).to be_a(WhatsrbCloud::Objects::BusinessAccount)
      expect(list.data.first.business_name).to eq('Acme')
    end
  end

  describe '#retrieve' do
    it 'returns a BusinessAccount object' do
      FakeServer.stub_get('/business_accounts/ba_1', response: {
                            'data' => {
                              'id' => 'ba_1', 'business_name' => 'Acme', 'status' => 'connected',
                              'quality_rating' => 'GREEN', 'connected' => true
                            }
                          })

      account = resource.retrieve('ba_1')
      expect(account.id).to eq('ba_1')
      expect(account.business_name).to eq('Acme')
      expect(account).to be_connected
    end
  end

  describe '#window' do
    it 'returns window data for a phone number' do
      stub_request(:get, "#{FakeServer::BASE}/business_accounts/ba_1/window?phone_number=%2B33600000001")
        .to_return(status: 200,
                   body: '{"data":{"phone_number":"+33600000001","open":true,"last_inbound_at":"2026-03-06T10:00:00Z","expires_at":"2026-03-07T10:00:00Z"}}',
                   headers: FakeServer.json_headers)

      result = resource.window('ba_1', phone_number: '+33600000001')
      expect(result['open']).to be(true)
      expect(result['phone_number']).to eq('+33600000001')
    end
  end
end
