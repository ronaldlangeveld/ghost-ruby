# frozen_string_literal: true

module Ghost
  module Authentication
    class ContentKey
      def initialize(key)
        @key = key
      end

      def apply(request)
        request.params["key"] = @key
      end
    end
  end
end
