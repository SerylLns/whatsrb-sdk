# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Objects::Agent do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  let(:agent_data) do
    {
      'id' => 'agt_1', 'name' => 'Concierge', 'description' => 'Hotel agent',
      'system_prompt' => 'You are a hotel agent', 'model' => 'gpt-4',
      'temperature' => 0.3, 'max_tokens' => 1024,
      'active' => true, 'auto_run_inbound' => true,
      'debounce_seconds' => 10, 'inbound_config' => {},
      'allowed_actions' => ['support.ticket.create', 'support.refund.process'],
      'tools' => [{ 'key' => 'propose_actions', 'name' => 'Propose Actions' }],
      'business_account_id' => 'ba_1',
      'created_at' => '2025-01-01T00:00:00Z', 'updated_at' => '2025-01-01T00:00:00Z'
    }
  end

  let(:agent) { described_class.new(agent_data, client: client) }

  describe '#active?' do
    it 'returns true when status is active' do
      expect(agent).to be_active
    end

    it 'returns false when active is false' do
      inactive = described_class.new(agent_data.merge('active' => false))
      expect(inactive).not_to be_active
    end
  end

  describe '#auto_run?' do
    it 'returns true when auto_run is true' do
      expect(agent).to be_auto_run
    end

    it 'returns false when auto_run_inbound is false' do
      manual = described_class.new(agent_data.merge('auto_run_inbound' => false))
      expect(manual).not_to be_auto_run
    end
  end

  describe '#allowed_actions' do
    it 'returns the allowed actions list' do
      expect(agent.allowed_actions).to eq(['support.ticket.create', 'support.refund.process'])
    end

    it 'defaults to empty array when not provided' do
      data = agent_data.reject { |k| k == 'allowed_actions' }
      a = described_class.new(data)
      expect(a.allowed_actions).to eq([])
    end
  end

  describe '#runs' do
    it 'returns AgentRuns resource scoped to agent' do
      expect(agent.runs).to be_a(WhatsrbCloud::Resources::AgentRuns)
    end
  end

  describe '#run_async' do
    it 'creates an agent run and returns immediately' do
      FakeServer.stub_post('/agents/agt_1/runs', response: {
                             'data' => { 'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'pending' }
                           })

      run = agent.run_async(input: { last_message: 'hello' })
      expect(run).to be_a(WhatsrbCloud::Objects::AgentRun)
      expect(run).to be_pending
    end
  end

  describe '#run' do
    it 'creates a run and polls until completed' do
      # Stub create
      FakeServer.stub_post('/agents/agt_1/runs', response: {
                             'data' => { 'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'pending' }
                           })

      # Stub polling — pending then completed
      call_count = 0
      stub_request(:get, "#{FakeServer::BASE}/agents/agt_1/runs/run_1")
        .to_return do
          call_count += 1
          body = if call_count < 2
                   { 'data' => { 'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'running' } }
                 else
                   { 'data' => { 'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'completed',
                                 'output' => { 'intent' => 'greeting' } } }
                 end
          { status: 200, body: JSON.generate(body), headers: FakeServer.json_headers }
        end

      run = agent.run(input: { last_message: 'hello' }, timeout: 10, interval: 0.01)
      expect(run).to be_completed
      expect(run.intent).to eq('greeting')
    end
  end

  describe '#reload' do
    it 'refreshes data from API and returns self' do
      FakeServer.stub_get('/agents/agt_1', response: {
                            'data' => agent_data.merge('name' => 'Updated', 'active' => false)
                          })

      result = agent.reload
      expect(result).to equal(agent)
      expect(agent.name).to eq('Updated')
      expect(agent).not_to be_active
    end
  end

  describe '#refresh' do
    it 'is an alias for reload' do
      expect(described_class.instance_method(:refresh)).to eq(described_class.instance_method(:reload))
    end
  end

  describe '#to_h' do
    it 'returns the raw data hash' do
      expect(agent.to_h).to eq(agent_data)
    end
  end
end
