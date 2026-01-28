# frozen_string_literal: true

module Ghost
  class Response
    include Enumerable

    attr_reader :raw

    def initialize(raw)
      @raw = raw
    end

    def data
      @data ||= raw[resource_key] || []
    end

    def first
      data.first
    end

    def meta
      raw["meta"]
    end

    def pagination
      meta&.dig("pagination")
    end

    def each(&block)
      data.each(&block)
    end

    def to_a
      data
    end

    private

    def resource_key
      @resource_key ||= raw.keys.find { |k| k != "meta" }
    end
  end
end
