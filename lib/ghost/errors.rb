# frozen_string_literal: true

module Ghost
  class Error < StandardError
    attr_reader :error_type, :context, :status_code

    def initialize(message = nil, error_type: nil, context: nil, status_code: nil)
      @error_type = error_type
      @context = context
      @status_code = status_code
      super(message)
    end

    def self.from_response(status, body)
      error_class = ERROR_MAP[status] || Error
      errors = body.is_a?(Hash) && body["errors"] ? body["errors"] : []

      if errors.any?
        err = errors.first
        error_class.new(
          err["message"],
          error_type: err["type"],
          context: err["context"],
          status_code: status
        )
      else
        error_class.new("Unknown error", status_code: status)
      end
    end
  end

  class BadRequestError < Error; end
  class AuthenticationError < Error; end
  class ForbiddenError < Error; end
  class NotFoundError < Error; end
  class UnprocessableError < Error; end
  class ServerError < Error; end

  ERROR_MAP = {
    400 => BadRequestError,
    401 => AuthenticationError,
    403 => ForbiddenError,
    404 => NotFoundError,
    422 => UnprocessableError,
    500 => ServerError
  }.freeze
end
