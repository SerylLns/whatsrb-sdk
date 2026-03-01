# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::Webhooks do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  describe '#list' do
    it 'returns a List of Webhook objects' do
      FakeServer.stub_get('/webhooks', response: {
                            'data' => [
                              { 'id' => 1, 'url' => 'https://example.com/hook', 'events' => ['message.received'],
                                'active' => true }
                            ],
                            'meta' => { 'total' => 1 }
                          })

      list = client.webhooks.list
      expect(list.data.size).to eq(1)
      expect(list.data.first).to be_a(WhatsrbCloud::Objects::Webhook)
      expect(list.data.first.url).to eq('https://example.com/hook')
      expect(list.data.first).to be_active
    end
  end

  describe '#create' do
    it 'creates a webhook, unwraps data, returns secret' do
      FakeServer.stub_post('/webhooks', response: {
                             'data' => {
                               'id' => 1, 'url' => 'https://example.com/hook',
                               'events' => ['message.received'], 'active' => true, 'secret' => 'whsec_abc123'
                             }
                           })

      wh = client.webhooks.create(url: 'https://example.com/hook', events: ['message.received'])
      expect(wh.id).to eq(1)
      expect(wh.secret).to eq('whsec_abc123')
      expect(wh.events).to eq(['message.received'])
    end

    it 'wraps params in webhook key' do
      stub = stub_request(:post, "#{FakeServer::BASE}/webhooks")
             .with(body: '{"webhook":{"url":"https://example.com/hook","events":["message.received"]}}')
             .to_return(status: 200,
                        body: '{"data":{"id":1}}',
                        headers: FakeServer.json_headers)

      client.webhooks.create(url: 'https://example.com/hook', events: ['message.received'])
      expect(stub).to have_been_requested
    end
  end

  describe '#retrieve' do
    it 'returns a Webhook object, unwrapping data' do
      FakeServer.stub_get('/webhooks/1', response: {
                            'data' => {
                              'id' => 1, 'url' => 'https://example.com/hook',
                              'events' => ['message.received'], 'active' => true
                            }
                          })

      wh = client.webhooks.retrieve(1)
      expect(wh.id).to eq(1)
    end
  end

  describe '#update' do
    it 'updates webhook events, wraps in webhook key' do
      stub = stub_request(:patch, "#{FakeServer::BASE}/webhooks/1")
             .with(body: '{"webhook":{"events":["message.received","session.connected"]}}')
             .to_return(status: 200,
                        body: '{"data":{"id":1,"events":["message.received","session.connected"],"active":true}}',
                        headers: FakeServer.json_headers)

      wh = client.webhooks.update(1, events: %w[message.received session.connected])
      expect(wh.events).to eq(%w[message.received session.connected])
      expect(stub).to have_been_requested
    end
  end

  describe '#delete' do
    it 'returns true on success' do
      FakeServer.stub_delete('/webhooks/1')
      expect(client.webhooks.delete(1)).to be true
    end
  end
end
