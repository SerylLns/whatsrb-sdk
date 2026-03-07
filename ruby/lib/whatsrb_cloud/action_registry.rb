# frozen_string_literal: true

module WhatsrbCloud
  class ActionRegistry
    def initialize
      @handlers = {}
    end

    # Register a handler for an action type
    #
    #   registry.register("support.ticket.create") { |action| ... }
    #
    def register(action_type, &handler)
      @handlers[action_type] = handler
      self
    end

    # Dispatch a single action to its registered handler
    #
    # Returns the handler's return value, or nil if no handler registered.
    def dispatch(action)
      action_type = action['type'] || action[:type]
      handler = @handlers[action_type]
      return nil unless handler

      payload = action['payload'] || action[:payload] || {}
      handler.call(payload)
    end

    # Dispatch multiple actions (e.g., from an AgentRun)
    def dispatch_all(actions)
      actions.map { |action| dispatch(action) }
    end

    def registered?(action_type)
      @handlers.key?(action_type)
    end

    def action_types
      @handlers.keys
    end
  end
end
