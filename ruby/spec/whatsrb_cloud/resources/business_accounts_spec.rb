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
end
