# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::Sessions do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  describe '#list' do
    it 'returns a List of Session objects' do
      FakeServer.stub_get('/sessions', response: {
                            'data' => [
                              { 'id' => 'sess_1', 'name' => 'Bot 1', 'status' => 'connected' },
                              { 'id' => 'sess_2', 'name' => 'Bot 2', 'status' => 'disconnected' }
                            ],
                            'meta' => { 'total' => 2, 'plan_limit' => 5 }
                          })

      list = client.sessions.list
      expect(list).to be_a(WhatsrbCloud::Objects::List)
      expect(list.data.size).to eq(2)
      expect(list.data.first).to be_a(WhatsrbCloud::Objects::Session)
      expect(list.data.first.name).to eq('Bot 1')
      expect(list.meta['total']).to eq(2)
    end
  end

  describe '#create' do
    it 'creates a session and returns a Session object' do
      FakeServer.stub_post('/sessions', response: {
                             'data' => { 'id' => 'sess_new', 'name' => 'My Bot', 'status' => 'connecting' }
                           })

      session = client.sessions.create(name: 'My Bot')
      expect(session).to be_a(WhatsrbCloud::Objects::Session)
      expect(session.id).to eq('sess_new')
      expect(session.name).to eq('My Bot')
    end

    it 'wraps params in session key' do
      stub = stub_request(:post, "#{FakeServer::BASE}/sessions")
             .with(body: '{"session":{"name":"My Bot"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"sess_new"}}',
                        headers: FakeServer.json_headers)

      client.sessions.create(name: 'My Bot')
      expect(stub).to have_been_requested
    end
  end

  describe '#retrieve' do
    it 'returns a Session object, unwrapping data' do
      FakeServer.stub_get('/sessions/sess_1', response: {
                            'data' => {
                              'id' => 'sess_1', 'name' => 'Bot', 'status' => 'connected',
                              'phone_number' => '+33612345678', 'qr_code' => nil
                            }
                          })

      session = client.sessions.retrieve('sess_1')
      expect(session.id).to eq('sess_1')
      expect(session.phone_number).to eq('+33612345678')
      expect(session).to be_connected
    end
  end

  describe '#delete' do
    it 'returns true on success' do
      FakeServer.stub_delete('/sessions/sess_1')
      expect(client.sessions.delete('sess_1')).to be true
    end
  end
end
