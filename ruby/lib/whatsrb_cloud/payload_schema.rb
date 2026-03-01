# frozen_string_literal: true

module WhatsrbCloud
  class PayloadSchema
    include Enumerable

    Field = Struct.new(:name, :field_type, :required, keyword_init: true) do
      def required? = required == true
      def to_h = { "name" => name, "field_type" => field_type, "required" => required }
    end

    Result = Struct.new(:fields, :payload, keyword_init: true) do
      def valid?
        missing.empty?
      end

      def missing
        @missing ||= fields.select(&:required?).reject { |f| present_value?(payload[f.name]) }.map { |f| f.name.to_sym }
      end

      def present
        @present ||= fields.select { |f| present_value?(payload[f.name]) }.map { |f| f.name.to_sym }
      end

      def to_h
        fields.each_with_object({}) { |f, h| h[f.name.to_sym] = payload[f.name] }
      end

      alias_method :to_hash, :to_h

      private

      def present_value?(value)
        !value.nil? && value != ""
      end
    end

    attr_reader :fields

    def initialize(raw = [])
      @raw = raw || []
      @fields = @raw.map do |f|
        Field.new(name: f["name"], field_type: f["field_type"], required: f["required"])
      end.freeze
    end

    def each(&block) = @fields.each(&block)

    def field_names
      @fields.map { |f| f.name.to_sym }
    end

    def required
      @fields.select(&:required?).map { |f| f.name.to_sym }
    end

    def check(payload)
      payload = normalize(payload)
      Result.new(fields: @fields, payload: payload)
    end

    def empty? = @fields.empty?
    def size = @fields.size

    def to_a
      @raw.dup
    end

    private

    def normalize(payload)
      return {} if payload.nil?

      payload.transform_keys(&:to_s)
    end
  end
end
