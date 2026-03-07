# frozen_string_literal: true

RSpec.describe WhatsrbCloud::EventRegistry do
  let(:registry) { described_class.new }

  describe '#on + #dispatch' do
    it 'dispatches to registered handler' do
      received = nil
      registry.on('agent_run.completed') { |data| received = data }
      registry.dispatch('event' => 'agent_run.completed', 'data' => { 'id' => 'run_1' })
      expect(received).to eq({ 'id' => 'run_1' })
    end

    it 'supports multiple handlers for the same event' do
      calls = []
      registry.on('agent_run.completed') { calls << :first }
      registry.on('agent_run.completed') { calls << :second }
      registry.dispatch('event' => 'agent_run.completed', 'data' => {})
      expect(calls).to eq(%i[first second])
    end

    it 'returns true when handlers exist' do
      registry.on('agent_run.completed') { nil }
      expect(registry.dispatch('event' => 'agent_run.completed', 'data' => {})).to be true
    end

    it 'returns false when no handler registered' do
      expect(registry.dispatch('event' => 'unknown', 'data' => {})).to be false
    end

    it 'ignores unregistered events' do
      called = false
      registry.on('agent_run.completed') { called = true }
      registry.dispatch('event' => 'message.received', 'data' => {})
      expect(called).to be false
    end
  end

  describe '#on chaining' do
    it 'returns self for fluent API' do
      result = registry.on('a') { nil }.on('b') { nil }
      expect(result).to equal(registry)
    end
  end

  describe '#registered?' do
    it 'returns true for registered events' do
      registry.on('agent_run.completed') { nil }
      expect(registry.registered?('agent_run.completed')).to be true
    end

    it 'returns false for unregistered events' do
      expect(registry.registered?('nope')).to be false
    end
  end

  describe '#event_types' do
    it 'lists registered event types' do
      registry.on('a') { nil }.on('b') { nil }
      expect(registry.event_types).to contain_exactly('a', 'b')
    end
  end
end
