# frozen_string_literal: true

module Ghost
  module Resources
    module Admin
      class Pages < Base
        actions :browse, :read, :add, :edit, :delete
      end
    end
  end
end
