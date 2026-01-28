# frozen_string_literal: true

RSpec.describe Ghost::Client do
  let(:config) do
    Ghost::Config.new(url: "https://demo.ghost.io", version: "v5.0", api_type: "content", key: "abc123")
  end
  let(:authenticator) { Ghost::Authentication::ContentKey.new("abc123") }
  let(:client) { described_class.new(config: config, authenticator: authenticator) }

  describe "#get" do
    it "makes a GET request and returns parsed JSON" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/")
        .with(query: hash_including("key" => "abc123"))
        .to_return(
          status: 200,
          body: { posts: [{ id: "1", title: "Hello" }] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = client.get("https://demo.ghost.io/ghost/api/content/posts/")
      expect(result["posts"].first["title"]).to eq("Hello")
    end

    it "sends Accept-Version header" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/")
        .with(
          query: hash_including("key" => "abc123"),
          headers: { "Accept-Version" => "v5.0" }
        )
        .to_return(status: 200, body: { posts: [] }.to_json)

      client.get("https://demo.ghost.io/ghost/api/content/posts/")
    end

    it "passes query parameters" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/")
        .with(query: hash_including("key" => "abc123", "limit" => "10", "include" => "authors"))
        .to_return(status: 200, body: { posts: [] }.to_json)

      client.get("https://demo.ghost.io/ghost/api/content/posts/", limit: "10", include: "authors")
    end
  end

  describe "#post" do
    let(:admin_config) do
      Ghost::Config.new(
        url: "https://demo.ghost.io", version: "v5.0", api_type: "admin",
        key: "6489e4a3b35e12d07a:93fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa"
      )
    end
    let(:admin_auth) do
      Ghost::Authentication::JwtToken.new(
        "6489e4a3b35e12d07a:93fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa"
      )
    end
    let(:admin_client) { described_class.new(config: admin_config, authenticator: admin_auth) }

    it "makes a POST request with JSON body" do
      stub_request(:post, "https://demo.ghost.io/ghost/api/admin/posts/")
        .with(
          body: { posts: [{ title: "Hello" }] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
        .to_return(
          status: 201,
          body: { posts: [{ id: "1", title: "Hello" }] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = admin_client.post(
        "https://demo.ghost.io/ghost/api/admin/posts/",
        { posts: [{ title: "Hello" }] }
      )
      expect(result["posts"].first["title"]).to eq("Hello")
    end
  end

  describe "#put" do
    let(:admin_config) do
      Ghost::Config.new(
        url: "https://demo.ghost.io", version: "v5.0", api_type: "admin",
        key: "6489e4a3b35e12d07a:93fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa"
      )
    end
    let(:admin_auth) do
      Ghost::Authentication::JwtToken.new(
        "6489e4a3b35e12d07a:93fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa"
      )
    end
    let(:admin_client) { described_class.new(config: admin_config, authenticator: admin_auth) }

    it "makes a PUT request with JSON body" do
      stub_request(:put, "https://demo.ghost.io/ghost/api/admin/posts/123/")
        .to_return(
          status: 200,
          body: { posts: [{ id: "123", title: "Updated" }] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = admin_client.put(
        "https://demo.ghost.io/ghost/api/admin/posts/123/",
        { posts: [{ title: "Updated" }] }
      )
      expect(result["posts"].first["title"]).to eq("Updated")
    end
  end

  describe "error handling" do
    it "raises NotFoundError for 404 responses" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/")
        .with(query: hash_including("key" => "abc123"))
        .to_return(
          status: 404,
          body: { errors: [{ message: "Resource not found", type: "NotFoundError" }] }.to_json
        )

      expect { client.get("https://demo.ghost.io/ghost/api/content/posts/") }
        .to raise_error(Ghost::NotFoundError, "Resource not found")
    end

    it "raises AuthenticationError for 401 responses" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/")
        .with(query: hash_including("key" => "abc123"))
        .to_return(
          status: 401,
          body: { errors: [{ message: "Invalid API key", type: "UnauthorizedError" }] }.to_json
        )

      expect { client.get("https://demo.ghost.io/ghost/api/content/posts/") }
        .to raise_error(Ghost::AuthenticationError, "Invalid API key")
    end

    it "raises ServerError for 500 responses" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/")
        .with(query: hash_including("key" => "abc123"))
        .to_return(
          status: 500,
          body: { errors: [{ message: "Internal server error", type: "InternalServerError" }] }.to_json
        )

      expect { client.get("https://demo.ghost.io/ghost/api/content/posts/") }
        .to raise_error(Ghost::ServerError, "Internal server error")
    end

    it "includes error details" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/")
        .with(query: hash_including("key" => "abc123"))
        .to_return(
          status: 422,
          body: {
            errors: [{
              message: "Validation failed",
              type: "ValidationError",
              context: "Title is required"
            }]
          }.to_json
        )

      begin
        client.get("https://demo.ghost.io/ghost/api/content/posts/")
      rescue Ghost::UnprocessableError => e
        expect(e.message).to eq("Validation failed")
        expect(e.error_type).to eq("ValidationError")
        expect(e.context).to eq("Title is required")
        expect(e.status_code).to eq(422)
      end
    end
  end
end
