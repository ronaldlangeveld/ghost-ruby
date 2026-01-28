# frozen_string_literal: true

module Ghost
  class ContentAPI
    RESOURCES = {
      posts: Resources::Content::Posts,
      pages: Resources::Content::Pages,
      authors: Resources::Content::Authors,
      tags: Resources::Content::Tags,
      settings: Resources::Content::Settings,
      tiers: Resources::Content::Tiers,
      newsletters: Resources::Content::Newsletters,
      offers: Resources::Content::Offers
    }.freeze

    def initialize(url:, key:, version: "v5.0")
      @config = Config.new(url: url, version: version, api_type: "content", key: key)
      authenticator = Authentication::ContentKey.new(key)
      @client = Client.new(config: @config, authenticator: authenticator)
      @resources = {}
    end

    RESOURCES.each do |name, klass|
      define_method(name) do
        @resources[name] ||= klass.new(client: @client, config: @config)
      end
    end
  end
end
