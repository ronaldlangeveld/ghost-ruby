# frozen_string_literal: true

RSpec.describe Ghost::Response do
  let(:raw_data) do
    {
      "posts" => [
        { "id" => "1", "title" => "First Post" },
        { "id" => "2", "title" => "Second Post" }
      ],
      "meta" => {
        "pagination" => {
          "page" => 1,
          "limit" => 15,
          "pages" => 1,
          "total" => 2
        }
      }
    }
  end

  subject { described_class.new(raw_data) }

  describe "#data" do
    it "returns the resource array" do
      expect(subject.data).to eq(raw_data["posts"])
    end

    it "returns empty array when resource key has no data" do
      response = described_class.new({ "meta" => {} })
      expect(response.data).to eq([])
    end
  end

  describe "#first" do
    it "returns the first resource" do
      expect(subject.first).to eq({ "id" => "1", "title" => "First Post" })
    end
  end

  describe "#meta" do
    it "returns the meta hash" do
      expect(subject.meta).to eq(raw_data["meta"])
    end
  end

  describe "#pagination" do
    it "returns pagination data" do
      expect(subject.pagination).to eq(raw_data["meta"]["pagination"])
    end

    it "returns nil when no meta" do
      response = described_class.new({ "posts" => [] })
      expect(response.pagination).to be_nil
    end
  end

  describe "#each" do
    it "iterates over data" do
      titles = subject.map { |post| post["title"] }
      expect(titles).to eq(["First Post", "Second Post"])
    end
  end

  describe "#to_a" do
    it "returns data as array" do
      expect(subject.to_a).to eq(raw_data["posts"])
    end
  end
end
