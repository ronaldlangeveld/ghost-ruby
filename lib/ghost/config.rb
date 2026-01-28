# frozen_string_literal: true

module Ghost
  class Config
    attr_reader :url, :version, :api_type

    def initialize(url:, version:, api_type:, key:)
      @url = url.to_s.chomp("/")
      @version = version
      @api_type = api_type
      @key = key

      validate!
    end

    def base_url
      "#{@url}/ghost/api/#{@api_type}"
    end

    def resource_url(resource)
      "#{base_url}/#{resource}/"
    end

    def resource_id_url(resource, id)
      "#{base_url}/#{resource}/#{id}/"
    end

    def resource_slug_url(resource, slug)
      "#{base_url}/#{resource}/slug/#{slug}/"
    end

    def resource_email_url(resource, email)
      "#{base_url}/#{resource}/email/#{email}/"
    end

    private

    def validate!
      raise Ghost::Error, "URL is required" if @url.nil? || @url.empty?
      raise Ghost::Error, "Version is required" if @version.nil? || @version.empty?
      raise Ghost::Error, "API key is required" if @key.nil? || @key.empty?

      uri = URI.parse(@url)
      raise Ghost::Error, "URL must include a protocol (https://)" unless uri.is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      raise Ghost::Error, "Invalid URL: #{@url}"
    end
  end
end
