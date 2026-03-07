# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class Agents
      def initialize(client:, connection:)
        @client     = client
        @connection = connection
      end

      def list
        response = @connection.get('/agents')
        data = (response['data'] || []).map { |a| Objects::Agent.new(a, client: @client) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def create(**params)
        response = @connection.post('/agents', { agent: params })
        Objects::Agent.new(response['data'], client: @client)
      end

      def retrieve(id)
        response = @connection.get("/agents/#{id}")
        Objects::Agent.new(response['data'], client: @client)
      end

      def update(id, **params)
        response = @connection.patch("/agents/#{id}", { agent: params })
        Objects::Agent.new(response['data'], client: @client)
      end

      def delete(id)
        @connection.delete("/agents/#{id}")
        true
      end

      # Raccourci : client.agents.runs('agt_xxx')
      def runs(agent_id)
        Resources::AgentRuns.new(client: @client, connection: @connection, agent_id: agent_id)
      end
    end
  end
end
