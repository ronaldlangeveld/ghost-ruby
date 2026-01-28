# frozen_string_literal: true

RSpec.describe Ghost::Authentication::ContentKey do
  let(:key) { "a1b2c3d4e5f6a1b2c3d4e5f6ab" }

  describe "#apply" do
    it "sets the key query parameter" do
      authenticator = described_class.new(key)
      request = double("request", params: {})

      authenticator.apply(request)

      expect(request.params["key"]).to eq(key)
    end
  end
end
