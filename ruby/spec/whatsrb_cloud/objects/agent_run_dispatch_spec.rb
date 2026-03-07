# frozen_string_literal: true

RSpec.describe 'AgentRun#dispatch' do
  let(:run_data) do
    {
      'id' => 'run_1', 'agent_id' => 'agt_1', 'status' => 'completed',
      'output' => {
        'actions' => [
          { 'type' => 'task.create', 'payload' => { 'room' => '204' } },
          { 'type' => 'ticket.create', 'payload' => { 'message' => 'Help' } }
        ]
      }
    }
  end

  let(:run) { WhatsrbCloud::Objects::AgentRun.new(run_data) }
  let(:registry) { WhatsrbCloud::ActionRegistry.new }

  it 'dispatches all actions through the registry' do
    results = []
    registry.register('task.create') { |p| results << "task:#{p['room']}" }
    registry.register('ticket.create') { |p| results << "ticket:#{p['message']}" }

    run.dispatch(registry)

    expect(results).to eq(['task:204', 'ticket:Help'])
  end

  it 'returns dispatch results' do
    registry.register('task.create') { :ok }
    registry.register('ticket.create') { :ok }

    expect(run.dispatch(registry)).to eq([:ok, :ok])
  end

  it 'handles runs with no actions' do
    empty_run = WhatsrbCloud::Objects::AgentRun.new(run_data.merge('output' => nil))
    expect(empty_run.dispatch(registry)).to eq([])
  end
end
