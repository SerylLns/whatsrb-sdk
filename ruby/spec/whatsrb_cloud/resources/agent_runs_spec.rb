# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Resources::AgentRuns do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  describe '#list' do
    it 'returns a List of AgentRun objects' do
      FakeServer.stub_get('/agents/agt_1/runs', response: {
                            'data' => [
                              { 'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'completed' },
                              { 'id' => 'run_2', 'agent_id' => 'agt_1', 'status' => 'pending' }
                            ],
                            'meta' => { 'total' => 2 }
                          })

      list = client.agent_runs('agt_1').list
      expect(list).to be_a(WhatsrbCloud::Objects::List)
      expect(list.data.size).to eq(2)
      expect(list.data.first).to be_a(WhatsrbCloud::Objects::AgentRun)
      expect(list.data.first.id).to eq('run_1')
    end
  end

  describe '#create' do
    it 'creates an agent run and returns an AgentRun object' do
      FakeServer.stub_post('/agents/agt_1/runs', response: {
                             'data' => { 'id' => 'run_new', 'agent_id' => 'agt_1', 'status' => 'pending' }
                           })

      run = client.agent_runs('agt_1').create(input: { last_message: 'hello' })
      expect(run).to be_a(WhatsrbCloud::Objects::AgentRun)
      expect(run).to be_pending
    end

    it 'wraps params in run key' do
      stub = stub_request(:post, "#{FakeServer::BASE}/agents/agt_1/runs")
             .with(body: '{"run":{"input":{"last_message":"hello"}}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"run_new","agent_id":"agt_1","status":"pending"}}',
                        headers: FakeServer.json_headers)

      client.agent_runs('agt_1').create(input: { last_message: 'hello' })
      expect(stub).to have_been_requested
    end

    it 'includes metadata when provided' do
      stub = stub_request(:post, "#{FakeServer::BASE}/agents/agt_1/runs")
             .with(body: '{"run":{"input":{"msg":"hi"},"metadata":{"source":"test"}}}')
             .to_return(status: 200,
                        body: '{"data":{"id":"run_new","agent_id":"agt_1","status":"pending"}}',
                        headers: FakeServer.json_headers)

      client.agent_runs('agt_1').create(input: { msg: 'hi' }, metadata: { source: 'test' })
      expect(stub).to have_been_requested
    end
  end

  describe '#retrieve' do
    it 'returns a single AgentRun object' do
      FakeServer.stub_get('/agents/agt_1/runs/run_1', response: {
                            'data' => { 'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'completed' }
                          })

      run = client.agent_runs('agt_1').retrieve('run_1')
      expect(run).to be_a(WhatsrbCloud::Objects::AgentRun)
      expect(run.id).to eq('run_1')
    end
  end
end
