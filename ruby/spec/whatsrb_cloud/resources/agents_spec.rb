# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::Agents do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  describe '#list' do
    it 'returns a List of Agent objects' do
      FakeServer.stub_get('/agents', response: {
                            'data' => [
                              { 'id' => 'agt_1', 'name' => 'Concierge', 'status' => 'active' },
                              { 'id' => 'agt_2', 'name' => 'Support', 'status' => 'inactive' }
                            ],
                            'meta' => { 'total' => 2 }
                          })

      list = client.agents.list
      expect(list).to be_a(WhatsrbCloud::Objects::List)
      expect(list.data.size).to eq(2)
      expect(list.data.first).to be_a(WhatsrbCloud::Objects::Agent)
      expect(list.data.first.name).to eq('Concierge')
      expect(list.meta['total']).to eq(2)
    end
  end

  describe '#create' do
    it 'creates an agent and returns an Agent object' do
      FakeServer.stub_post('/agents', response: {
                             'data' => { 'id' => 'agt_new', 'name' => 'Concierge', 'status' => 'active' }
                           })

      agent = client.agents.create(name: 'Concierge', system_prompt: 'You are a hotel agent')
      expect(agent).to be_a(WhatsrbCloud::Objects::Agent)
      expect(agent.id).to eq('agt_new')
    end

    it 'wraps params in agent key' do
      stub = stub_request(:post, "#{FakeServer::BASE}/agents")
             .with(body: '{"agent":{"name":"Concierge"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"agt_new"}}',
                        headers: FakeServer.json_headers)

      client.agents.create(name: 'Concierge')
      expect(stub).to have_been_requested
    end
  end

  describe '#retrieve' do
    it 'returns a single Agent object' do
      FakeServer.stub_get('/agents/agt_1', response: {
                            'data' => { 'id' => 'agt_1', 'name' => 'Concierge', 'status' => 'active' }
                          })

      agent = client.agents.retrieve('agt_1')
      expect(agent).to be_a(WhatsrbCloud::Objects::Agent)
      expect(agent.id).to eq('agt_1')
    end
  end

  describe '#update' do
    it 'updates and returns the Agent object' do
      FakeServer.stub_patch('/agents/agt_1', response: {
                              'data' => { 'id' => 'agt_1', 'name' => 'Updated', 'status' => 'active' }
                            })

      agent = client.agents.update('agt_1', name: 'Updated')
      expect(agent.name).to eq('Updated')
    end

    it 'wraps params in agent key' do
      stub = stub_request(:patch, "#{FakeServer::BASE}/agents/agt_1")
             .with(body: '{"agent":{"name":"Updated"}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"agt_1","name":"Updated"}}',
                        headers: FakeServer.json_headers)

      client.agents.update('agt_1', name: 'Updated')
      expect(stub).to have_been_requested
    end
  end

  describe '#delete' do
    it 'returns true on success' do
      FakeServer.stub_delete('/agents/agt_1')
      expect(client.agents.delete('agt_1')).to be true
    end
  end

  describe '#runs' do
    it 'returns AgentRuns resource scoped to agent' do
      expect(client.agents.runs('agt_1')).to be_a(WhatsrbCloud::Resources::AgentRuns)
    end
  end
end
