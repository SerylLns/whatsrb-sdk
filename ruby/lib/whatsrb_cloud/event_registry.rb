# frozen_string_literal: true

module WhatsrbCloud
  class EventRegistry
    def initialize
      @handlers = {}
    end

    # Register a handler for an event type
    #
    #   registry.on("agent_run.completed") { |data| ... }
    #
    def on(event_type, &handler)
      (@handlers[event_type] ||= []) << handler
      self
    end

    # Dispatch a webhook payload to registered handlers
    #
    #   registry.dispatch("event" => "agent_run.completed", "data" => {...})
    #
    def dispatch(payload)
      event_type = payload['event'] || payload[:event]
      data = payload['data'] || payload[:data] || payload
      handlers = @handlers[event_type]
      return false unless handlers

      handlers.each { |h| h.call(data) }
      true
    end

    def registered?(event_type)
      @handlers.key?(event_type)
    end

    def event_types
      @handlers.keys
    end
  end
end
