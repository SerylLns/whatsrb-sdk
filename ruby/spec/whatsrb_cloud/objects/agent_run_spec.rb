# frozen_string_literal: true

RSpec.describe WhatsrbCloud::Objects::AgentRun do
  let(:client) { WhatsrbCloud::Client.new(api_key: 'wrb_live_test') }

  let(:run_data) do
    {
      'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'completed',
      'triggered_by' => 'sdk',
      'input' => { 'last_message' => 'Clean room 204' },
      'output' => {
        'intent' => 'task_extraction', 'confidence' => 0.95,
        'actions' => [{ 'type' => 'create_task', 'room' => '204' }]
      },
      'error' => nil,
      'model_used' => 'gpt-4o-mini', 'input_tokens' => 512, 'output_tokens' => 128,
      'latency_ms' => 1200, 'duration_ms' => 1500,
      'started_at' => '2025-01-01T00:00:01Z',
      'completed_at' => '2025-01-01T00:00:02Z', 'created_at' => '2025-01-01T00:00:00Z'
    }
  end

  let(:run) { described_class.new(run_data, client: client) }

  describe 'status predicates' do
    it '#pending? returns true when pending' do
      pending_run = described_class.new(run_data.merge('status' => 'pending'))
      expect(pending_run).to be_pending
    end

    it '#running? returns true when running' do
      running_run = described_class.new(run_data.merge('status' => 'running'))
      expect(running_run).to be_running
    end

    it '#completed? returns true when completed' do
      expect(run).to be_completed
    end

    it '#failed? returns true when failed' do
      failed_run = described_class.new(run_data.merge('status' => 'failed'))
      expect(failed_run).to be_failed
    end

    it '#finished? returns true when completed or failed' do
      expect(run).to be_finished
      failed_run = described_class.new(run_data.merge('status' => 'failed'))
      expect(failed_run).to be_finished
    end
  end

  describe 'metrics accessors' do
    it '#triggered_by returns the trigger source' do
      expect(run.triggered_by).to eq('sdk')
    end

    it '#model_used returns the model' do
      expect(run.model_used).to eq('gpt-4o-mini')
    end

    it '#input_tokens returns token count' do
      expect(run.input_tokens).to eq(512)
    end

    it '#output_tokens returns token count' do
      expect(run.output_tokens).to eq(128)
    end

    it '#latency_ms returns LLM latency' do
      expect(run.latency_ms).to eq(1200)
    end

    it '#duration_ms returns total duration' do
      expect(run.duration_ms).to eq(1500)
    end

    it 'returns nil for metrics when not present' do
      minimal = described_class.new({ 'id' => 'run_x', 'status' => 'pending' })
      expect(minimal.model_used).to be_nil
      expect(minimal.input_tokens).to be_nil
    end
  end

  describe 'output accessors' do
    it '#intent returns the intent from output' do
      expect(run.intent).to eq('task_extraction')
    end

    it '#confidence returns the confidence from output' do
      expect(run.confidence).to eq(0.95)
    end

    it '#actions returns the actions array from output' do
      expect(run.actions).to eq([{ 'type' => 'create_task', 'room' => '204' }])
    end

    it '#actions returns empty array when output is nil' do
      empty_run = described_class.new(run_data.merge('output' => nil))
      expect(empty_run.actions).to eq([])
    end

    it '#intent returns nil when output is nil' do
      empty_run = described_class.new(run_data.merge('output' => nil))
      expect(empty_run.intent).to be_nil
    end
  end

  describe '#wait' do
    it 'polls until completed and returns self' do
      call_count = 0
      stub_request(:get, "#{FakeServer::BASE}/agents/agt_1/runs/run_1")
        .to_return do
          call_count += 1
          body = if call_count < 3
                   { 'data' => { 'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'running' } }
                 else
                   { 'data' => run_data }
                 end
          { status: 200, body: JSON.generate(body), headers: FakeServer.json_headers }
        end

      pending_run = described_class.new(run_data.merge('status' => 'pending'), client: client)
      result = pending_run.wait(timeout: 10, interval: 0.01)

      expect(result).to equal(pending_run)
      expect(result).to be_completed
    end

    it 'raises on failure' do
      stub_request(:get, "#{FakeServer::BASE}/agents/agt_1/runs/run_1")
        .to_return(
          status: 200,
          body: JSON.generate({ 'data' => run_data.merge('status' => 'failed', 'error' => 'boom') }),
          headers: FakeServer.json_headers
        )

      pending_run = described_class.new(run_data.merge('status' => 'pending'), client: client)
      expect { pending_run.wait(timeout: 10, interval: 0.01) }
        .to raise_error(WhatsrbCloud::Error, /Agent run failed: boom/)
    end

    it 'raises on timeout' do
      stub_request(:get, "#{FakeServer::BASE}/agents/agt_1/runs/run_1")
        .to_return(
          status: 200,
          body: JSON.generate({ 'data' => run_data.merge('status' => 'running') }),
          headers: FakeServer.json_headers
        )

      pending_run = described_class.new(run_data.merge('status' => 'pending'), client: client)
      expect { pending_run.wait(timeout: 0.02, interval: 0.01) }
        .to raise_error(WhatsrbCloud::Error, /Timed out/)
    end
  end

  describe '#reload' do
    it 'refreshes data from API and returns self' do
      FakeServer.stub_get('/agents/agt_1/runs/run_1', response: {
                            'data' => run_data.merge('status' => 'completed', 'output' => { 'intent' => 'updated' })
                          })

      pending_run = described_class.new(run_data.merge('status' => 'running'), client: client)
      result = pending_run.reload

      expect(result).to equal(pending_run)
      expect(pending_run).to be_completed
      expect(pending_run.intent).to eq('updated')
    end
  end

  describe '#refresh' do
    it 'is an alias for reload' do
      expect(described_class.instance_method(:refresh)).to eq(described_class.instance_method(:reload))
    end
  end

  describe '#to_h' do
    it 'returns the raw data hash' do
      expect(run.to_h).to eq(run_data)
    end
  end
end
