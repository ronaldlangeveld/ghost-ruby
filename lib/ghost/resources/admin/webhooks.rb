# frozen_string_literal: true

module Ghost
  module Resources
    module Admin
      class Webhooks < Base
        actions :add, :edit, :delete
      end
    end
  end
end
