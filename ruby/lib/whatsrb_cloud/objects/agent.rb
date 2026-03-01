# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class Agent
      attr_reader :id, :name, :description, :system_prompt, :model,
                  :temperature, :max_tokens, :active, :auto_run_inbound,
                  :debounce_seconds, :inbound_config, :payload_schema, :tools,
                  :business_account_id, :created_at, :updated_at

      def initialize(data, client: nil)
        @id                   = data['id']
        @name                 = data['name']
        @description          = data['description']
        @system_prompt        = data['system_prompt']
        @model                = data['model']
        @temperature          = data['temperature']
        @max_tokens           = data['max_tokens']
        @active               = data['active']
        @auto_run_inbound     = data['auto_run_inbound']
        @debounce_seconds     = data['debounce_seconds']
        @inbound_config       = data['inbound_config']
        @payload_schema       = data['payload_schema']
        @tools                = data['tools']
        @business_account_id  = data['business_account_id']
        @created_at           = data['created_at']
        @updated_at           = data['updated_at']
        @client               = client
        @raw                  = data
      end

      def active?   = @active == true
      def auto_run? = @auto_run_inbound == true

      # Sync — crée un run et poll jusqu'à terminé
      def run(input:, metadata: nil, timeout: 30, interval: 1)
        run_async(input: input, metadata: metadata).wait(timeout: timeout, interval: interval)
      end

      # Async — crée un run et retourne immédiatement
      def run_async(input:, metadata: nil)
        runs.create(input: input, metadata: metadata)
      end

      def runs
        @client.agent_runs(@id)
      end

      def reload
        refreshed = @client.agents.retrieve(@id)
        @name              = refreshed.name
        @description       = refreshed.description
        @system_prompt     = refreshed.system_prompt
        @model             = refreshed.model
        @temperature       = refreshed.temperature
        @max_tokens        = refreshed.max_tokens
        @active            = refreshed.active
        @auto_run_inbound  = refreshed.auto_run_inbound
        @debounce_seconds  = refreshed.debounce_seconds
        @inbound_config    = refreshed.inbound_config
        @payload_schema    = refreshed.payload_schema
        @tools             = refreshed.tools
        @updated_at        = refreshed.updated_at
        self
      end

      alias_method :refresh, :reload

      def to_h
        @raw
      end
    end
  end
end
