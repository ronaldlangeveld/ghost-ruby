# frozen_string_literal: true

RSpec.describe Ghost::AdminAPI do
  let(:url) { "https://demo.ghost.io" }
  let(:admin_key) { "6489e4a3b35e12d07a:93fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa" }
  let(:api) { described_class.new(url: url, key: admin_key, version: "v5.0") }

  let(:posts_response) do
    {
      posts: [
        { id: "1", title: "First Post" },
        { id: "2", title: "Second Post" }
      ],
      meta: { pagination: { page: 1, limit: 15, pages: 1, total: 2 } }
    }.to_json
  end

  let(:single_post_response) do
    { posts: [{ id: "1", title: "Hello World" }] }.to_json
  end

  describe "#posts" do
    it "returns an Admin::Posts resource" do
      expect(api.posts).to be_a(Ghost::Resources::Admin::Posts)
    end
  end

  describe "posts.browse" do
    it "fetches posts" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/admin/posts/")
        .to_return(status: 200, body: posts_response)

      response = api.posts.browse
      expect(response.data.length).to eq(2)
    end
  end

  describe "posts.read" do
    it "fetches a post by id" do
      stub_request(:get, "https://demo.ghost.io/ghost/api/admin/posts/1/")
        .to_return(status: 200, body: single_post_response)

      response = api.posts.read(id: "1")
      expect(response.first["title"]).to eq("Hello World")
    end
  end

  describe "posts.add" do
    it "creates a post" do
      stub_request(:post, "https://demo.ghost.io/ghost/api/admin/posts/")
        .with(body: { posts: [{ title: "New Post", html: "<p>Content</p>" }] }.to_json)
        .to_return(
          status: 201,
          body: { posts: [{ id: "new-id", title: "New Post" }] }.to_json
        )

      response = api.posts.add(title: "New Post", html: "<p>Content</p>")
      expect(response.first["title"]).to eq("New Post")
    end
  end

  describe "posts.edit" do
    it "updates a post" do
      stub_request(:put, "https://demo.ghost.io/ghost/api/admin/posts/1/")
        .with(body: { posts: [{ title: "Updated Title" }] }.to_json)
        .to_return(
          status: 200,
          body: { posts: [{ id: "1", title: "Updated Title" }] }.to_json
        )

      response = api.posts.edit(id: "1", title: "Updated Title")
      expect(response.first["title"]).to eq("Updated Title")
    end

    it "raises error without id" do
      expect { api.posts.edit(title: "No ID") }
        .to raise_error(Ghost::Error, "edit requires an id")
    end
  end

  describe "posts.delete" do
    it "deletes a post" do
      stub_request(:delete, "https://demo.ghost.io/ghost/api/admin/posts/1/")
        .to_return(status: 204, body: "")

      result = api.posts.delete(id: "1")
      expect(result).to eq(true)
    end

    it "raises error without id" do
      expect { api.posts.delete }
        .to raise_error(Ghost::Error, "delete requires an id")
    end
  end

  describe "resource accessors" do
    it("provides posts") { expect(api.posts).to be_a(Ghost::Resources::Admin::Posts) }
    it("provides pages") { expect(api.pages).to be_a(Ghost::Resources::Admin::Pages) }
    it("provides tags") { expect(api.tags).to be_a(Ghost::Resources::Admin::Tags) }
    it("provides members") { expect(api.members).to be_a(Ghost::Resources::Admin::Members) }
    it("provides users") { expect(api.users).to be_a(Ghost::Resources::Admin::Users) }
    it("provides newsletters") { expect(api.newsletters).to be_a(Ghost::Resources::Admin::Newsletters) }
    it("provides tiers") { expect(api.tiers).to be_a(Ghost::Resources::Admin::Tiers) }
    it("provides offers") { expect(api.offers).to be_a(Ghost::Resources::Admin::Offers) }
    it("provides webhooks") { expect(api.webhooks).to be_a(Ghost::Resources::Admin::Webhooks) }
    it("provides site") { expect(api.site).to be_a(Ghost::Resources::Admin::Site) }
    it("provides images") { expect(api.images).to be_a(Ghost::Resources::Admin::Images) }
    it("provides media") { expect(api.media).to be_a(Ghost::Resources::Admin::Media) }
    it("provides files") { expect(api.files).to be_a(Ghost::Resources::Admin::Files) }
    it("provides themes") { expect(api.themes).to be_a(Ghost::Resources::Admin::Themes) }
  end

  describe "admin-specific actions" do
    it "webhooks do not respond to browse or read" do
      expect(api.webhooks).not_to respond_to(:browse)
      expect(api.webhooks).not_to respond_to(:read)
    end

    it "webhooks respond to add, edit, delete" do
      expect(api.webhooks).to respond_to(:add)
      expect(api.webhooks).to respond_to(:edit)
      expect(api.webhooks).to respond_to(:delete)
    end

    it "users only respond to browse and read" do
      expect(api.users).to respond_to(:browse)
      expect(api.users).to respond_to(:read)
      expect(api.users).not_to respond_to(:add)
      expect(api.users).not_to respond_to(:edit)
      expect(api.users).not_to respond_to(:delete)
    end

    it "images only respond to upload" do
      expect(api.images).to respond_to(:upload)
      expect(api.images).not_to respond_to(:browse)
    end
  end
end
