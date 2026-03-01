# frozen_string_literal: true

module WhatsrbCloud
  module Resources
    class Templates
      def initialize(connection:, account_id:)
        @connection = connection
        @account_id = account_id
      end

      def list(status: nil, category: nil)
        params = []
        params << "status=#{status}" if status
        params << "category=#{category}" if category
        path = base_path
        path += "?#{params.join('&')}" unless params.empty?
        response = @connection.get(path)
        data = (response['data'] || []).map { |t| Objects::Template.new(t) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def find_by_name(name)
        list.data.find { |t| t.name == name }
      end

      def retrieve(template_id)
        response = @connection.get("#{base_path}/#{template_id}")
        Objects::Template.new(response['data'])
      end

      def create(**params)
        response = @connection.post(base_path, { template: params })
        Objects::Template.new(response['data'])
      end

      def delete(template_id)
        @connection.delete("#{base_path}/#{template_id}")
        true
      end

      def sync
        response = @connection.post("#{base_path}/sync")
        data = (response['data'] || []).map { |t| Objects::Template.new(t) }
        Objects::List.new(data: data, meta: response['meta'] || {})
      end

      def clone(template_id)
        response = @connection.post("#{base_path}/#{template_id}/clone")
        Objects::Template.new(response['data'])
      end

      def send_test(template_id, to:, variables: [])
        body = { to: to }
        body[:variables] = variables unless variables.empty?
        response = @connection.post("#{base_path}/#{template_id}/send_test", body)
        Objects::Message.new(response['data'])
      end

      private

      def base_path
        "/business_accounts/#{@account_id}/templates"
      end
    end
  end
end
