# frozen_string_literal: true

module Ghost
  class AdminAPI
    RESOURCES = {
      posts: Resources::Admin::Posts,
      pages: Resources::Admin::Pages,
      tags: Resources::Admin::Tags,
      members: Resources::Admin::Members,
      users: Resources::Admin::Users,
      newsletters: Resources::Admin::Newsletters,
      tiers: Resources::Admin::Tiers,
      offers: Resources::Admin::Offers,
      webhooks: Resources::Admin::Webhooks,
      site: Resources::Admin::Site,
      images: Resources::Admin::Images,
      media: Resources::Admin::Media,
      files: Resources::Admin::Files,
      themes: Resources::Admin::Themes
    }.freeze

    def initialize(url:, key:, version: "v5.0")
      @config = Config.new(url: url, version: version, api_type: "admin", key: key)
      authenticator = Authentication::JwtToken.new(key)
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
