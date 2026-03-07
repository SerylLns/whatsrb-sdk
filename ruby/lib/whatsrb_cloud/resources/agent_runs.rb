# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class AgentRuns
      def initialize(client:, connection:, agent_id:)
        @client     = client
        @connection = connection
        @agent_id   = agent_id
      end

      def list
        response = @connection.get(base_path)
        data = (response['data'] || []).map { |r| Objects::AgentRun.new(r, client: @client) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def create(input:, metadata: nil)
        body = { input: input }
        body[:metadata] = metadata if metadata
        response = @connection.post(base_path, { run: body })
        Objects::AgentRun.new(response['data'], client: @client)
      end

      def retrieve(id)
        response = @connection.get("#{base_path}/#{id}")
        Objects::AgentRun.new(response['data'], client: @client)
      end

      private

      def base_path
        "/agents/#{@agent_id}/runs"
      end
    end
  end
end
