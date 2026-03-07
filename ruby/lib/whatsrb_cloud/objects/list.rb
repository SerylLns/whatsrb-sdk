# frozen_string_literal: true

module WhatsrbCloud
  module Objects
    class List
      include Enumerable

      attr_reader :data, :meta

      def initialize(data:, meta:)
        @data = data
        @meta = meta
      end

      def each(&) = @data.each(&)
      def size     = @data.size
      def empty?   = @data.empty?

      alias_method :length, :size
    end
  end
end
