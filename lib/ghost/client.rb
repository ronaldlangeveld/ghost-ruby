# frozen_string_literal: true

require "faraday"
require "faraday/multipart"
require "json"

module Ghost
  class Client
    def initialize(config:, authenticator:)
      @config = config
      @authenticator = authenticator
      @connection = build_connection
    end

    def get(url, params = {})
      request(:get, url, params)
    end

    def post(url, body = {})
      request(:post, url, body)
    end

    def put(url, body = {})
      request(:put, url, body)
    end

    def delete(url)
      request(:delete, url)
    end

    def upload(url, file_path, ref: nil)
      mime = detect_mime(file_path)
      payload = {
        file: Faraday::Multipart::FilePart.new(file_path, mime)
      }
      payload[:ref] = ref if ref

      response = @connection.post(url) do |req|
        @authenticator.apply(req)
        req.headers["Accept-Version"] = @config.version
        req.body = payload
      end

      handle_response(response)
    end

    private

    def build_connection
      Faraday.new do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter Faraday.default_adapter
      end
    end

    def request(method, url, params_or_body = nil)
      response = @connection.send(method, url) do |req|
        @authenticator.apply(req)
        req.headers["Accept-Version"] = @config.version
        req.headers["Content-Type"] = "application/json" if %i[post put].include?(method)

        case method
        when :get
          req.params.merge!(params_or_body) if params_or_body&.any?
        when :post, :put
          req.body = JSON.generate(params_or_body) if params_or_body
        end
      end

      handle_response(response)
    end

    def handle_response(response)
      body = response.body.is_a?(String) && !response.body.empty? ? JSON.parse(response.body) : {}

      unless response.success?
        raise Ghost::Error.from_response(response.status, body)
      end

      body
    end

    def detect_mime(file_path)
      ext = File.extname(file_path).downcase
      {
        ".png" => "image/png",
        ".jpg" => "image/jpeg",
        ".jpeg" => "image/jpeg",
        ".gif" => "image/gif",
        ".svg" => "image/svg+xml",
        ".webp" => "image/webp",
        ".mp4" => "video/mp4",
        ".webm" => "video/webm",
        ".ogv" => "video/ogg",
        ".mp3" => "audio/mpeg",
        ".zip" => "application/zip",
        ".pdf" => "application/pdf",
        ".json" => "application/json",
        ".css" => "text/css"
      }.fetch(ext, "application/octet-stream")
    end
  end
end
