# frozen_string_literal: true

RSpec.describe WhatsrbCloud::ActionRegistry do
  let(:registry) { described_class.new }

  describe '#register + #dispatch' do
    it 'dispatches payload to registered handler' do
      received = nil
      registry.register('support.ticket.create') { |payload| received = payload }
      registry.dispatch('type' => 'support.ticket.create', 'payload' => { 'message' => 'Help!' })
      expect(received).to eq({ 'message' => 'Help!' })
    end

    it 'returns the handler result' do
      registry.register('task.create') { |p| "created: #{p['room']}" }
      result = registry.dispatch('type' => 'task.create', 'payload' => { 'room' => '204' })
      expect(result).to eq('created: 204')
    end

    it 'returns nil for unregistered action types' do
      expect(registry.dispatch('type' => 'unknown')).to be_nil
    end

    it 'overwrites previous handler for same type' do
      registry.register('a') { :first }
      registry.register('a') { :second }
      expect(registry.dispatch('type' => 'a')).to eq(:second)
    end

    it 'passes empty hash when payload is missing' do
      received = nil
      registry.register('a') { |p| received = p }
      registry.dispatch('type' => 'a')
      expect(received).to eq({})
    end
  end

  describe '#dispatch_all' do
    it 'dispatches multiple actions and returns results' do
      registry.register('task.create') { |p| "task:#{p['room']}" }
      registry.register('ticket.create') { |p| "ticket:#{p['msg']}" }

      actions = [
        { 'type' => 'task.create', 'payload' => { 'room' => '204' } },
        { 'type' => 'ticket.create', 'payload' => { 'msg' => 'Help' } },
        { 'type' => 'unknown' }
      ]

      results = registry.dispatch_all(actions)
      expect(results).to eq(['task:204', 'ticket:Help', nil])
    end
  end

  describe '#register chaining' do
    it 'returns self for fluent API' do
      result = registry.register('a') { nil }.register('b') { nil }
      expect(result).to equal(registry)
    end
  end

  describe '#registered?' do
    it 'returns true for registered action types' do
      registry.register('a') { nil }
      expect(registry.registered?('a')).to be true
    end
  end

  describe '#action_types' do
    it 'lists registered action types' do
      registry.register('a') { nil }.register('b') { nil }
      expect(registry.action_types).to contain_exactly('a', 'b')
    end
  end
end
