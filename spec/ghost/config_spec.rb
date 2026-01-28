# frozen_string_literal: true

RSpec.describe Ghost::Config do
  let(:valid_params) { { url: "https://demo.ghost.io", version: "v5.0", api_type: "content", key: "abc123" } }

  describe "#initialize" do
    it "accepts valid parameters" do
      config = described_class.new(**valid_params)
      expect(config.url).to eq("https://demo.ghost.io")
      expect(config.version).to eq("v5.0")
      expect(config.api_type).to eq("content")
    end

    it "strips trailing slash from URL" do
      config = described_class.new(**valid_params.merge(url: "https://demo.ghost.io/"))
      expect(config.url).to eq("https://demo.ghost.io")
    end

    it "raises error when URL is missing" do
      expect { described_class.new(**valid_params.merge(url: "")) }
        .to raise_error(Ghost::Error, "URL is required")
    end

    it "raises error when version is missing" do
      expect { described_class.new(**valid_params.merge(version: "")) }
        .to raise_error(Ghost::Error, "Version is required")
    end

    it "raises error when key is missing" do
      expect { described_class.new(**valid_params.merge(key: "")) }
        .to raise_error(Ghost::Error, "API key is required")
    end

    it "raises error when URL has no protocol" do
      expect { described_class.new(**valid_params.merge(url: "demo.ghost.io")) }
        .to raise_error(Ghost::Error, /URL must include a protocol/)
    end
  end

  describe "#base_url" do
    it "constructs content API base URL" do
      config = described_class.new(**valid_params)
      expect(config.base_url).to eq("https://demo.ghost.io/ghost/api/content")
    end

    it "constructs admin API base URL" do
      config = described_class.new(**valid_params.merge(api_type: "admin"))
      expect(config.base_url).to eq("https://demo.ghost.io/ghost/api/admin")
    end
  end

  describe "#resource_url" do
    it "constructs resource URL" do
      config = described_class.new(**valid_params)
      expect(config.resource_url("posts")).to eq("https://demo.ghost.io/ghost/api/content/posts/")
    end
  end

  describe "#resource_id_url" do
    it "constructs resource URL with id" do
      config = described_class.new(**valid_params)
      expect(config.resource_id_url("posts", "abc123")).to eq("https://demo.ghost.io/ghost/api/content/posts/abc123/")
    end
  end

  describe "#resource_slug_url" do
    it "constructs resource URL with slug" do
      config = described_class.new(**valid_params)
      expect(config.resource_slug_url("posts", "hello-world")).to eq("https://demo.ghost.io/ghost/api/content/posts/slug/hello-world/")
    end
  end

  describe "#resource_email_url" do
    it "constructs resource URL with email" do
      config = described_class.new(**valid_params)
      expect(config.resource_email_url("members", "test@example.com")).to eq("https://demo.ghost.io/ghost/api/content/members/email/test@example.com/")
    end
  end
end
