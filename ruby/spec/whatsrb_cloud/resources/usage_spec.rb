# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::Usage do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  describe '#fetch' do
    it 'returns usage data unwrapped from data key' do
      FakeServer.stub_get('/usage', response: {
                            'data' => {
                              'plan' => 'pro',
                              'sessions' => { 'used' => 3, 'limit' => 5 },
                              'daily_messages' => { 'used' => 150, 'limit' => 10_000, 'remaining' => 9850 }
                            }
                          })

      result = client.usage
      expect(result['plan']).to eq('pro')
      expect(result['sessions']['used']).to eq(3)
      expect(result['daily_messages']['remaining']).to eq(9850)
    end
  end
end
