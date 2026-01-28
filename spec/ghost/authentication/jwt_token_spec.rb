# frozen_string_literal: true

RSpec.describe Ghost::Authentication::JwtToken do
  let(:id) { "6489e4a3b35e12d07a" }
  let(:secret) { "93fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa25c8b293fa" }
  let(:key) { "#{id}:#{secret}" }

  describe "#initialize" do
    it "accepts a valid key format" do
      expect { described_class.new(key) }.not_to raise_error
    end

    it "raises error for invalid key format" do
      expect { described_class.new("invalid-key") }
        .to raise_error(Ghost::Error, /Admin API key must be in format/)
    end

    it "raises error for key without secret" do
      expect { described_class.new("onlyid") }
        .to raise_error(Ghost::Error, /Admin API key must be in format/)
    end
  end

  describe "#apply" do
    it "sets the Authorization header with Ghost token" do
      authenticator = described_class.new(key)
      request = double("request", headers: {})

      authenticator.apply(request)

      expect(request.headers["Authorization"]).to match(/\AGhost .+\z/)
    end

    it "produces a valid JWT token" do
      authenticator = described_class.new(key)
      request = double("request", headers: {})

      authenticator.apply(request)

      token = request.headers["Authorization"].sub("Ghost ", "")
      decoded = JWT.decode(token, [secret].pack("H*"), true, algorithm: "HS256")
      payload = decoded[0]
      header = decoded[1]

      expect(header["kid"]).to eq(id)
      expect(header["alg"]).to eq("HS256")
      expect(payload["aud"]).to eq("/admin/")
      expect(payload["exp"]).to be > payload["iat"]
    end

    it "caches the token between calls" do
      authenticator = described_class.new(key)
      request1 = double("request", headers: {})
      request2 = double("request", headers: {})

      authenticator.apply(request1)
      authenticator.apply(request2)

      expect(request1.headers["Authorization"]).to eq(request2.headers["Authorization"])
    end
  end
end
