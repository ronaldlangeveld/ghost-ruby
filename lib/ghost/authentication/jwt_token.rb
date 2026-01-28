# frozen_string_literal: true

require "jwt"

module Ghost
  module Authentication
    class JwtToken
      TOKEN_EXPIRY = 300 # 5 minutes
      REFRESH_BUFFER = 60 # refresh 1 minute before expiry

      def initialize(key)
        parts = key.to_s.split(":")
        raise Ghost::Error, "Admin API key must be in format {id}:{secret}" unless parts.length == 2

        @id = parts[0]
        @secret = [parts[1]].pack("H*")
        @token = nil
        @expires_at = nil
      end

      def apply(request)
        request.headers["Authorization"] = "Ghost #{token}"
      end

      private

      def token
        if @token.nil? || Time.now.to_i >= (@expires_at - REFRESH_BUFFER)
          generate_token
        end
        @token
      end

      def generate_token
        now = Time.now.to_i
        payload = {
          iat: now,
          exp: now + TOKEN_EXPIRY,
          aud: "/admin/"
        }
        @expires_at = now + TOKEN_EXPIRY
        @token = JWT.encode(payload, @secret, "HS256", { kid: @id })
      end
    end
  end
end
