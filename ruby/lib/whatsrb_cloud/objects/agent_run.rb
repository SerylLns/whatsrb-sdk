# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class AgentRun
      attr_reader :id, :agent_id, :status, :triggered_by, :input, :output,
                  :error, :model_used, :input_tokens, :output_tokens,
                  :latency_ms, :duration_ms,
                  :started_at, :completed_at, :created_at

      def initialize(data, client: nil)
        @id            = data['id']
        @agent_id      = data['agent_id']
        @status        = data['status']
        @triggered_by  = data['triggered_by']
        @input         = data['input']
        @output        = data['output']
        @error         = data['error']
        @model_used    = data['model_used']
        @input_tokens  = data['input_tokens']
        @output_tokens = data['output_tokens']
        @latency_ms    = data['latency_ms']
        @duration_ms   = data['duration_ms']
        @started_at    = data['started_at']
        @completed_at  = data['completed_at']
        @created_at    = data['created_at']
        @client       = client
        @raw          = data
      end

      # Status predicates
      def pending?   = @status == 'pending'
      def running?   = @status == 'running'
      def completed? = @status == 'completed'
      def failed?    = @status == 'failed'
      def finished?  = completed? || failed?

      # Output accessors
      def intent     = @output&.dig('intent')
      def confidence = @output&.dig('confidence')
      def actions    = @output&.dig('actions') || []

      # Dispatch actions through an ActionRegistry
      def dispatch(registry)
        registry.dispatch_all(actions)
      end

      def wait(timeout: 30, interval: 1)
        deadline = Time.now + timeout

        loop do
          reload
          return self if completed?
          raise WhatsrbCloud::Error, "Agent run failed: #{@error}" if failed?
          raise WhatsrbCloud::Error, "Timed out waiting for agent run #{@id}" if Time.now >= deadline

          sleep(interval)
        end
      end

      def reload
        refreshed = @client.agent_runs(@agent_id).retrieve(@id)
        @status        = refreshed.status
        @triggered_by  = refreshed.triggered_by
        @output        = refreshed.output
        @error         = refreshed.error
        @model_used    = refreshed.model_used
        @input_tokens  = refreshed.input_tokens
        @output_tokens = refreshed.output_tokens
        @latency_ms    = refreshed.latency_ms
        @duration_ms   = refreshed.duration_ms
        @started_at    = refreshed.started_at
        @completed_at  = refreshed.completed_at
        self
      end

      alias_method :refresh, :reload

      def to_h
        @raw
      end
    end
  end
end
