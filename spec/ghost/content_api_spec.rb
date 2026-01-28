# frozen_string_literal: true

RSpec.describe Ghost::ContentAPI do
  let(:url) { "https://demo.ghost.io" }
  let(:key) { "a1b2c3d4e5f6a1b2c3d4e5f6ab" }
  let(:api) { described_class.new(url: url, key: key, version: "v5.0") }

  let(:posts_response) do
    {
      posts: [
        { id: "1", title: "First Post", slug: "first-post" },
        { id: "2", title: "Second Post", slug: "second-post" }
      ],
      meta: { pagination: { page: 1, limit: 15, pages: 1, total: 2 } }
    }.to_json
  end

  let(:single_post_response) do
    {
      posts: [{ id: "1", title: "First Post", slug: "first-post" }]
    }.to_json
  end

  describe "#posts" do
    it "returns a Content::Posts resource" do
      expect(api.posts).to be_a(Ghost::Resources::Content::Posts)
    end

    it "caches the resource instance" do
      expect(api.posts).to equal(api.posts)
    end
  end

  describe "posts.browse" do
    it "fetches posts with query params" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/")
        .with(query: hash_including("key" => key, "include" => "authors,tags", "limit" => "10"))
        .to_return(status: 200, body: posts_response)

      response = api.posts.browse(include: "authors,tags", limit: "10")

      expect(response).to be_a(Ghost::Response)
      expect(response.data.length).to eq(2)
      expect(response.first["title"]).to eq("First Post")
      expect(response.pagination["total"]).to eq(2)
    end
  end

  describe "posts.read" do
    it "fetches a post by id" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/1/")
        .with(query: hash_including("key" => key))
        .to_return(status: 200, body: single_post_response)

      response = api.posts.read(id: "1")
      expect(response.first["title"]).to eq("First Post")
    end

    it "fetches a post by slug" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/content/posts/slug/first-post/")
        .with(query: hash_including("key" => key))
        .to_return(status: 200, body: single_post_response)

      response = api.posts.read(slug: "first-post")
      expect(response.first["slug"]).to eq("first-post")
    end

    it "raises error when no identifier provided" do
      expect { api.posts.read }
        .to raise_error(Ghost::Error, "read requires an id, slug, or email")
    end
  end

  describe "resource accessors" do
    it "provides access to pages" do
      expect(api.pages).to be_a(Ghost::Resources::Content::Pages)
    end

    it "provides access to authors" do
      expect(api.authors).to be_a(Ghost::Resources::Content::Authors)
    end

    it "provides access to tags" do
      expect(api.tags).to be_a(Ghost::Resources::Content::Tags)
    end

    it "provides access to settings" do
      expect(api.settings).to be_a(Ghost::Resources::Content::Settings)
    end

    it "provides access to tiers" do
      expect(api.tiers).to be_a(Ghost::Resources::Content::Tiers)
    end

    it "provides access to newsletters" do
      expect(api.newsletters).to be_a(Ghost::Resources::Content::Newsletters)
    end

    it "provides access to offers" do
      expect(api.offers).to be_a(Ghost::Resources::Content::Offers)
    end
  end

  describe "read-only enforcement" do
    it "does not respond to add" do
      expect(api.posts).not_to respond_to(:add)
    end

    it "does not respond to edit" do
      expect(api.posts).not_to respond_to(:edit)
    end

    it "does not respond to delete" do
      expect(api.posts).not_to respond_to(:delete)
    end
  end
end
