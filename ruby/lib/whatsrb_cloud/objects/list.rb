# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class List
      attr_reader :data, :meta

      def initialize(data:, meta:)
        @data = data
        @meta = meta
      end
    end
  end
end
